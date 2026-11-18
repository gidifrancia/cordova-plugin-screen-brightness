# cordova-plugin-screen-brightness

Set the screen brightness of a Cordova app, for example to full brightness while
a QR code or a barcode is shown to a scanner, and give the user's brightness back
afterwards.

- **Android**: changes only the brightness of the app window. No permission is
  needed and the system setting is never written: when the user leaves the app
  the screen goes back to the system brightness by itself.
- **iOS**: the brightness is the one of the whole device, so the plugin keeps the
  user's value, puts it back when the app stops being active (home, app switcher,
  incoming call) and applies the requested value again when the app returns.

On both platforms a reload of the WebView gives the user's brightness back.

## Install

```bash
cordova plugin add cordova-plugin-screen-brightness
```

Requires cordova-android 10+ and cordova-ios 6+.

## Usage

The plugin is available after `deviceready` as `cordova.plugins.screenBrightness`.
Every method takes optional `success` and `error` callbacks; without callbacks it
returns a Promise.

```js
var brightness = cordova.plugins.screenBrightness;

// full brightness while the code is on screen
brightness.setBrightness(1);

// back to the user's brightness when the code is closed
brightness.reset();

// current brightness, from 0 to 1
brightness.getBrightness().then(function (value) {
    console.log(value);
});
```

### `setBrightness(value, [success], [error])`

`value` goes from `0` (darkest) to `1` (brightest). Any other value calls `error`.

### `reset([success], [error])`

Gives the screen back the user's brightness. Calling it when no brightness was
set does nothing.

### `getBrightness([success], [error])`

The current brightness, from `0` to `1`. On Android, when the app has not set one,
the value comes from the system setting and can be approximate on devices whose
brightness scale is not 0-255.

## License

MIT
