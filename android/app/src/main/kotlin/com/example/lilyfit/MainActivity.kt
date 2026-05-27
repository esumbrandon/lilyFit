package app.cypherwave.lilyfit

import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        applyHighRefreshRate()
    }

    /**
     * Requests the highest refresh rate supported by the device display.
     * On Android 6+ (API 23) we pick the display mode whose refresh rate is
     * highest and tell the window to prefer it. The OS will honour the request
     * as long as no other constraint (battery saver, system policy, …) prevents
     * it. On devices that only support 60 Hz this is a no-op.
     */
    private fun applyHighRefreshRate() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val display = window.decorView.display ?: return
            val supportedModes = display.supportedModes

            // Find the mode with the highest refresh rate.
            val bestMode = supportedModes.maxByOrNull { it.refreshRate } ?: return

            val params = window.attributes
            params.preferredDisplayModeId = bestMode.modeId
            window.attributes = params
        }
    }
}
