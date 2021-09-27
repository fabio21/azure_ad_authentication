#import "AzureAdAuthenticationPlugin.h"
#if __has_include(<azure_ad_authentication/azure_ad_authentication-Swift.h>)
#import <azure_ad_authentication/azure_ad_authentication-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "azure_ad_authentication-Swift.h"
#endif

@implementation AzureAdAuthenticationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAzureAdAuthenticationPlugin registerWithRegistrar:registrar];
}
@end
