var exec = require('cordova/exec');

var SERVICE = 'ScreenBrightness';

// Without callbacks the call returns a Promise (when the WebView has one).
function run(action, args, success, error) {
    if (!success && !error && typeof Promise !== 'undefined') {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, SERVICE, action, args);
        });
    }
    exec(success, error, SERVICE, action, args);
}

module.exports = {
    /**
     * Sets the brightness of the app, from 0 (darkest) to 1 (brightest).
     * Android: only the app window, the system setting is untouched.
     * iOS: the whole screen; the plugin puts back the user's brightness when
     * the app goes to the background and applies the value again when it returns.
     */
    setBrightness: function (value, success, error) {
        return run('setBrightness', [value], success, error);
    },

    /**
     * Current brightness, from 0 to 1. On Android, when the app has not set one,
     * it is read from the system setting (approximate on some devices).
     */
    getBrightness: function (success, error) {
        return run('getBrightness', [], success, error);
    },

    /** Gives the screen back the user's brightness. */
    reset: function (success, error) {
        return run('reset', [], success, error);
    }
};
