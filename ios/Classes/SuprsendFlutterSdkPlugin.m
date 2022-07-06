#import "SuprsendFlutterSdkPlugin.h"
#if __has_include(<suprsend_flutter_sdk/suprsend_flutter_sdk-Swift.h>)
#import <suprsend_flutter_sdk/suprsend_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "suprsend_flutter_sdk-Swift.h"
#endif

@implementation SuprsendFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSuprsendFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
