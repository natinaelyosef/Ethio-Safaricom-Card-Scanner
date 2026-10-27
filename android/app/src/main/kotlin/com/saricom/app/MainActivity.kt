package com.saricom.app

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * The single native surface Saricom needs on Android: `openUssd`, which
 * runs a USSD session *from inside the app* without ever opening the
 * phone dialer.
 *
 * Strategy, in order:
 *
 *  1. `TelephonyManager.sendUssdRequest` (API 26+): the network's own
 *     reply text comes back through [TelephonyManager.UssdResponseCallback] — the whole
 *     session completes inside Saricom and Dart shows it verbatim.
 *     No permission is required for this path.
 *
 *  2. `ACTION_CALL` (requires the CALL_PHONE runtime permission, which
 *     the Dart layer requests first): starts the session so the carrier's
 *     regular pop-up appears over this app. Saricom still reports only
 *     "session started" — the carrier dialog is the authority.
 *     On dual-SIM devices the call is placed on the requested
 *     subscription's phone account so the code runs on the SIM the user
 *     chose in Settings.
 *
 * If both paths are unavailable (sendUssdRequest refused + CALL_PHONE
 * denied) the channel answers `noPermission` and the UI explains inside
 * the app. The tel: dialer app is never opened from here.
 *
 * Result strings understood by `lib/services/ussd_service.dart`:
 *   ussdResponse:<network reply text> | direct | noPermission | failed:<why>
 *
 * An optional accessibility reader ([UssdAccessibilityService]) can capture
 * the carrier pop-up text when the fallback path is used; it forwards the
 * text to Dart via the `ussdPopup` method call on the same channel.
 *
 * Channel methods:
 *   openUssd({code, subscriptionId?}) -> String
 *   listSims() -> JSON string array of {subId, slot, carrierName,
 *                 displayName, number}
 *   armUssdCapture / isUssdReaderEnabled / openUssdReaderSettings
 */
class MainActivity : FlutterActivity() {

    private val channelName = "saricom/platform"
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channelRef = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openUssd" -> {
                    val code = call.argument<String>("code")
                    if (code == null || !validUssdShape(code)) {
                        result.error("invalid", "That is not a USSD code", null)
                    } else {
                        // -1 / absent = device default SIM.
                        val subId = call.argument<Int>("subscriptionId") ?: -1
                        openUssd(code, subId, result)
                    }
                }
                "listSims" -> listSims(result)
                "armUssdCapture" -> {
                    val seconds = call.argument<Int>("seconds") ?: 35
                    ussdCaptureUntil =
                        System.currentTimeMillis() + seconds.coerceIn(5, 120) * 1000L
                    result.success(null)
                }
                "isUssdReaderEnabled" -> result.success(isUssdReaderEnabled())
                "openUssdReaderSettings" -> {
                    try {
                        startActivity(
                            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("settings", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isUssdReaderEnabled(): Boolean {
        val component =
            ComponentName(this, UssdAccessibilityService::class.java)
        val enabled = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false
        return enabled.split(':').any {
            it.equals(component.flattenToString(), ignoreCase = true) ||
                it.equals(component.flattenToShortString(), ignoreCase = true)
        }
    }

    private fun validUssdShape(code: String): Boolean =
        code.startsWith("*") && code.endsWith("#") &&
            code.dropLast(1).drop(1).all { it.isDigit() || it == '*' }

    // ------------------------------------------------------------------
    // SIM list (dual-SIM support)
    // ------------------------------------------------------------------

    private fun listSims(result: MethodChannel.Result) {
        Thread({
            try {
                val granted =
                    checkSelfPermission(Manifest.permission.READ_PHONE_STATE) ==
                        PackageManager.PERMISSION_GRANTED
                if (!granted) {
                    deliver(result, "noPermission")
                    return@Thread
                }
                val sm = getSystemService(SubscriptionManager::class.java)
                val active = sm.activeSubscriptionInfoList ?: emptyList()
                val array = JSONArray()
                for (info: SubscriptionInfo in active) {
                    val entry = JSONObject().apply {
                        put("subId", info.subscriptionId)
                        put("slot", info.simSlotIndex)
                        put(
                            "carrierName",
                            info.carrierName?.toString() ?: "",
                        )
                        put(
                            "displayName",
                            info.displayName?.toString() ?: "",
                        )
                        put("number", info.number ?: "")
                    }
                    array.put(entry)
                }
                deliver(result, array.toString())
            } catch (e: Exception) {
                deliver(result, "failed:${e.javaClass.simpleName}")
            }
        }, "saricom-sims").apply {
            isDaemon = true
            start()
        }
    }

    /// TelephonyManager bound to a specific SIM subscription.
    private fun telephonyFor(subId: Int): TelephonyManager {
        val base = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        if (subId > 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return base.createForSubscriptionId(subId)
        }
        return base
    }

    // ------------------------------------------------------------------
    // Path 1: in-app USSD via TelephonyManager (API 26+, most devices)
    // ------------------------------------------------------------------

    private fun openUssd(code: String, subId: Int, result: MethodChannel.Result) {
        // The whole request runs off the main thread so a slow network
        // reply (or a device that never calls the callback) can wait out
        // its cap without freezing the Flutter UI.
        Thread({ runUssdSession(code, subId, result) }, "saricom-ussd").apply {
            isDaemon = true
            start()
        }
    }

    private fun runUssdSession(code: String, subId: Int, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            // sendUssdRequest does not exist; go straight to the fallback.
            deliverInAppFailedAndFallback(code, subId, result)
            return
        }
        val latch = CountDownLatch(1)
        var reply: String? = null
        var failure: String? = null

        val callback = object : TelephonyManager.UssdResponseCallback() {
            override fun onReceiveUssdResponse(
                telephonyManager: TelephonyManager,
                request: String,
                response: CharSequence,
            ) {
                reply = response.toString()
                latch.countDown()
            }

            override fun onReceiveUssdResponseFailed(
                telephonyManager: TelephonyManager,
                request: String,
                failureCode: Int,
            ) {
                failure = "ussd-failure-$failureCode"
                latch.countDown()
            }
        }

        val telephony = telephonyFor(subId)
        try {
            // The only public signature takes a Handler. The callback is
            // posted there, but WE wait on this worker thread — so even a
            // callback routed through the frozen main thread never
            // deadlocks the session logic.
            telephony.sendUssdRequest(code, callback, mainHandler)
        } catch (e: Exception) {
            deliverInAppFailedAndFallback(code, subId, result, e.message)
            return
        }

        // USSD replies usually land in < 1 s; cap the wait so a device
        // that never calls the callback still reaches the fallback.
        val got = try {
            latch.await(6, TimeUnit.SECONDS)
        } catch (_: InterruptedException) {
            false
        }

        when {
            got && reply != null ->
                deliver(result, "ussdResponse:$reply")
            got && failure != null ->
                // Network refused the in-app session → carrier pop-up path.
                fallbackToDirectCall(code, subId, result, "in-app: $failure")
            else ->
                // No answer at all (device blocks the API) → carrier pop-up.
                fallbackToDirectCall(code, subId, result, "in-app: no callback")
        }
    }

    private fun deliverInAppFailedAndFallback(
        code: String,
        subId: Int,
        result: MethodChannel.Result,
        why: String? = null,
    ) = fallbackToDirectCall(code, subId, result, "in-app unsupported${why?.let { " ($it)" } ?: ""}")

    private fun deliver(result: MethodChannel.Result, value: String) {
        mainHandler.post { result.success(value) }
    }

    // ------------------------------------------------------------------
    // Path 2: direct ACTION_CALL — carrier pop-up over this app
    // ------------------------------------------------------------------

    private fun fallbackToDirectCall(
        code: String,
        subId: Int,
        result: MethodChannel.Result,
        why: String,
    ) {
        mainHandler.post {
            try {
                val granted =
                    checkSelfPermission(Manifest.permission.CALL_PHONE) ==
                        PackageManager.PERMISSION_GRANTED
                if (!granted) {
                    deliver(result, "noPermission")
                    return@post
                }
                ussdCaptureUntil = System.currentTimeMillis() + 35_000L
                val placed = if (subId > 0) {
                    placeCallOnSubscription(code, subId)
                } else {
                    false
                }
                if (!placed) {
                    val intent = Intent(
                        Intent.ACTION_CALL,
                        Uri.parse("tel:" + Uri.encode(code)),
                    ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    // Allow the opt-in reader to capture the carrier dialog text
                    // that will appear over this app.
                    startActivity(intent)
                }
                deliver(result, "direct|$why")
            } catch (e: Exception) {
                deliver(result, "failed:${e.javaClass.simpleName}")
            }
        }
    }

    /**
     * Places the USSD call on a specific SIM using [TelecomManager] and
     * the subscription's phone-account handle (handle.id == subId string,
     * registered in [onCreate]). Returns false when unavailable so the
     * caller falls back to the plain ACTION_CALL intent on the device
     * default SIM.
     */
    private fun placeCallOnSubscription(code: String, subId: Int): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
        return try {
            val telecom = getSystemService(TelecomManager::class.java) ?: return false
            val handle = PhoneAccountHandle(
                ComponentName(this, DualSimCallService::class.java),
                subId.toString(),
            )
            // Hand the subscription to the ConnectionService via a static:
            // reading it back from ConnectionRequest is not reliably
            // available on all compile SDKs.
            pendingSubId = subId
            telecom.placeCall(
                Uri.parse("tel:" + Uri.encode(code)),
                Bundle().apply {
                    putParcelable(
                        TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE,
                        handle,
                    )
                },
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * Registers one phone account per active SIM so the fallback USSD
     * path can target a chosen subscription (see [DualSimCallService]).
     */
    private fun registerSimPhoneAccounts() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        try {
            val granted =
                checkSelfPermission(Manifest.permission.READ_PHONE_STATE) ==
                    PackageManager.PERMISSION_GRANTED
            if (!granted) return
            val telecom = getSystemService(TelecomManager::class.java) ?: return
            val sm = getSystemService(SubscriptionManager::class.java) ?: return
            val active = sm.activeSubscriptionInfoList ?: return
            for (info: SubscriptionInfo in active) {
                val handle = PhoneAccountHandle(
                    ComponentName(this, DualSimCallService::class.java),
                    info.subscriptionId.toString(),
                )
                val label = info.carrierName?.toString()
                    ?.takeIf { it.isNotBlank() }
                    ?: (info.displayName?.toString() ?: "SIM ${info.simSlotIndex + 1}")
                telecom.registerPhoneAccount(
                    PhoneAccount.builder(handle, label)
                        // CAPABILITY_PLACE_CALL == 1; the constant is not
                        // visible to every compile SDK stub, but the value
                        // is part of the public API contract.
                        .setCapabilities(1)
                        .build(),
                )
            }
        } catch (_: Exception) {
            // Optional; the plain ACTION_CALL path still works.
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerSimPhoneAccounts()
    }

    companion object {
        /** Millisecond deadline until which pop-up capture is allowed. */
        @Volatile
        var ussdCaptureUntil: Long = 0L

        /**
         * Subscription id handed to [DualSimCallService] right before a
         * SIM-targeted placeCall; read once by the service's outgoing
         * connection, then reset.
         */
        @Volatile
        var pendingSubId: Int = -1

        private var channelRef: MethodChannel? = null
        private val captureHandler = Handler(Looper.getMainLooper())

        /** Called by [UssdAccessibilityService] when it reads the USSD reply. */
        fun deliverUssdPopup(text: String) {
            val channel = channelRef ?: return
            // One reply per request; disarm immediately.
            ussdCaptureUntil = 0L
            captureHandler.post {
                try {
                    channel.invokeMethod("ussdPopup", text)
                } catch (_: Exception) {
                    // Flutter engine already detached; nothing to deliver to.
                }
            }
        }
    }
}
