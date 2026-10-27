package com.saricom.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * Opt-in reader for the carrier's own USSD pop-up.
 *
 * Some Android devices refuse `TelephonyManager.sendUssdRequest`, so
 * Saricom falls back to `ACTION_CALL` and the carrier dialog is rendered
 * by the phone/dialer app. Android does not expose that text to normal
 * apps; with the user's explicit consent (Settings → Accessibility) this
 * service reads the dialog and forwards it to Saricom so the balance or
 * recharge reply can be parsed in-app.
 *
 * Privacy guards:
 *  - It only acts while [MainActivity.ussdCaptureUntil] is in the future,
 *    i.e. for a few seconds after a Saricom USSD request.
 *  - The accessibility config restricts it to phone/dialer packages.
 *  - Text is forwarded once to the running app; nothing is stored.
 */
class UssdAccessibilityService : AccessibilityService() {

    private var lastText: String = ""
    private var lastDeliveredAt: Long = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        if (System.currentTimeMillis() > MainActivity.ussdCaptureUntil) return

        val builder = StringBuilder()
        for (text in event.text) {
            if (!text.isNullOrBlank()) builder.append(text).append('\n')
        }
        val root: AccessibilityNodeInfo? = rootInActiveWindow
        if (root != null) {
            collectText(root, builder, 0)
        }

        val captured = builder.toString().trim()
        if (captured.length < 6) return
        if (!looksLikeCarrierReply(captured)) return

        val now = System.currentTimeMillis()
        if (captured == lastText && now - lastDeliveredAt < 2000) return
        lastText = captured
        lastDeliveredAt = now
        MainActivity.deliverUssdPopup(captured)
    }

    private fun collectText(
        node: AccessibilityNodeInfo,
        out: StringBuilder,
        depth: Int,
    ) {
        if (depth > 12) return
        node.text?.let { if (it.isNotBlank()) out.append(it).append('\n') }
        node.contentDescription?.let {
            if (it.isNotBlank()) out.append(it).append('\n')
        }
        for (index in 0 until node.childCount) {
            val child = node.getChild(index) ?: continue
            collectText(child, out, depth + 1)
        }
    }

    /**
     * Accept only text that looks like a carrier reply. A plain phone
     * number or the dialing screen must never be mistaken for a balance.
     */
    private fun looksLikeCarrierReply(text: String): Boolean {
        val lower = text.lowercase()
        val strongKeywords = listOf(
            "balance", "birr", "etb", "airtime", "recharge", "voucher",
            "successful", "success", "failed", "invalid", "expired",
            "used", "not valid", "insufficient", "credited", "top up",
            "topup", "card", "ሂሳብ", "ቀሪ", "ብር", "ካርድ", "ተሳክቷል",
            "አልተሳካም", "ስልክ",
        )
        return strongKeywords.any { lower.contains(it) }
    }

    override fun onInterrupt() {
        // Nothing to interrupt: this service only observes events.
    }
}
