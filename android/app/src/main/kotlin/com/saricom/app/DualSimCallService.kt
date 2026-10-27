package com.saricom.app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.DisconnectCause
import android.telecom.PhoneAccountHandle

/**
 * Minimal [ConnectionService] that lets Saricom place a USSD call on a
 * *specific* SIM subscription on dual-SIM phones.
 *
 * How it works:
 *
 * 1. [MainActivity.onCreate] registers one [android.telecom.PhoneAccount]
 *    per active subscription, with handle id = the subscription id as a
 *    string, and this service's [PhoneAccountHandle] as the component.
 * 2. When a USSD session must run on a chosen SIM, the app calls
 *    [android.telecom.TelecomManager.placeCall] with that handle; Telecom
 *    routes the outgoing "call" here.
 * 3. We immediately dial the `tel:` intent ourselves (with the
 *    `subscription` extra so the dialer uses the right SIM), then close
 *    the synthetic connection — the carrier's USSD pop-up appears over
 *    the app exactly as with the plain ACTION_CALL fallback.
 *
 * No audio/media path is used; the connection exists only long enough to
 * hand the dial to the correct SIM.
 */
class DualSimCallService : ConnectionService() {

    override fun onCreateOutgoingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?,
    ): Connection {
        val connection = object : Connection() {}
        connection.setDialing()

        val address = request?.address
        // The subscription id was staged by MainActivity right before
        // placeCall; reading it from ConnectionRequest is not reliably
        // available on every compile SDK.
        val subId = MainActivity.pendingSubId.takeIf { it > 0 }
        MainActivity.pendingSubId = -1
        if (address != null && address.scheme == "tel") {
            try {
                val intent = Intent(Intent.ACTION_CALL, Uri.parse(address.toString()))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (subId != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    // SubscriptionManager.EXTRA_SUBSCRIPTION_INDEX
                    intent.putExtra("subscription", subId)
                }
                startActivity(intent)
            } catch (_: Exception) {
                // Fall through to disconnect; caller reports "failed".
            }
        }

        connection.setDisconnected(DisconnectCause(DisconnectCause.LOCAL))
        connection.destroy()
        return connection
    }
}
