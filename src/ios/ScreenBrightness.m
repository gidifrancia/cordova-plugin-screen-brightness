#import "ScreenBrightness.h"
#import <UIKit/UIKit.h>

// On iOS UIScreen.brightness is the brightness of the whole device and it stays
// after the app is left: the plugin keeps the user's value and puts it back when
// the app is no longer active, then applies the requested value again on return.
@implementation ScreenBrightness {
    BOOL _overriding;
    CGFloat _userBrightness;
    CGFloat _requestedBrightness;
}

- (void)pluginInitialize
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setBrightness:(CDVInvokedUrlCommand*)command
{
    id argument = [command argumentAtIndex:0];
    if (![argument isKindOfClass:[NSNumber class]] || [argument doubleValue] < 0 || [argument doubleValue] > 1) {
        [self sendError:@"brightness must be a number between 0 and 1" to:command];
        return;
    }
    CGFloat value = [argument doubleValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self->_overriding) {
            self->_userBrightness = [UIScreen mainScreen].brightness;
            self->_overriding = YES;
        }
        self->_requestedBrightness = value;
        [UIScreen mainScreen].brightness = value;
        [self sendOk:command];
    });
}

- (void)getBrightness:(CDVInvokedUrlCommand*)command
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                   messageAsDouble:[UIScreen mainScreen].brightness];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

- (void)reset:(CDVInvokedUrlCommand*)command
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self restoreUserBrightness];
        [self sendOk:command];
    });
}

// Reload or navigation of the WebView: the page that asked for the brightness is gone.
- (void)onReset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self restoreUserBrightness];
    });
}

- (void)restoreUserBrightness
{
    if (_overriding) {
        [UIScreen mainScreen].brightness = _userBrightness;
        _overriding = NO;
    }
}

- (void)appWillResignActive
{
    if (_overriding) {
        [UIScreen mainScreen].brightness = _userBrightness;
    }
}

- (void)appDidBecomeActive
{
    if (_overriding) {
        // the user may have changed the brightness while the app was not active
        _userBrightness = [UIScreen mainScreen].brightness;
        [UIScreen mainScreen].brightness = _requestedBrightness;
    }
}

- (void)sendOk:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendError:(NSString*)message to:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
