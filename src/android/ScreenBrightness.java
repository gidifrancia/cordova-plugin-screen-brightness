package it.gidifrancia.brightness;

import android.app.Activity;
import android.provider.Settings;
import android.view.Window;
import android.view.WindowManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;

/**
 * Brightness of the app window (WindowManager.LayoutParams.screenBrightness).
 * It applies only while the app is in the foreground and needs no permission:
 * the system brightness setting is never written.
 */
public class ScreenBrightness extends CordovaPlugin {

    private static final float MAX_SYSTEM_BRIGHTNESS = 255f;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
        switch (action) {
            case "setBrightness":
                double value = args.optDouble(0, Double.NaN);
                if (Double.isNaN(value) || value < 0 || value > 1) {
                    callbackContext.error("brightness must be a number between 0 and 1");
                    return true;
                }
                applyWindowBrightness((float) value, callbackContext);
                return true;
            case "getBrightness":
                readBrightness(callbackContext);
                return true;
            case "reset":
                applyWindowBrightness(WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE, callbackContext);
                return true;
            default:
                return false;
        }
    }

    /** Reload or navigation of the WebView: the page that asked for the brightness is gone. */
    @Override
    public void onReset() {
        applyWindowBrightness(WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE, null);
    }

    private void applyWindowBrightness(final float value, final CallbackContext callbackContext) {
        final Activity activity = cordova.getActivity();
        activity.runOnUiThread(() -> {
            Window window = activity.getWindow();
            WindowManager.LayoutParams params = window.getAttributes();
            params.screenBrightness = value;
            window.setAttributes(params);
            if (callbackContext != null) {
                callbackContext.success();
            }
        });
    }

    private void readBrightness(final CallbackContext callbackContext) {
        final Activity activity = cordova.getActivity();
        activity.runOnUiThread(() -> {
            float windowBrightness = activity.getWindow().getAttributes().screenBrightness;
            if (windowBrightness >= 0) {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, windowBrightness));
                return;
            }
            try {
                int system = Settings.System.getInt(activity.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS);
                float brightness = Math.min(1f, system / MAX_SYSTEM_BRIGHTNESS);
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, brightness));
            } catch (Settings.SettingNotFoundException e) {
                callbackContext.error("system brightness not available");
            }
        });
    }
}
