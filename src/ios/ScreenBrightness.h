#import <Cordova/CDVPlugin.h>

@interface ScreenBrightness : CDVPlugin

- (void)setBrightness:(CDVInvokedUrlCommand*)command;
- (void)getBrightness:(CDVInvokedUrlCommand*)command;
- (void)reset:(CDVInvokedUrlCommand*)command;

@end
