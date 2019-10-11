#import <UIKit/UIKit.h>
#include <dlfcn.h>

static NSString *k_YourViewing_Plist_Path = @"/var/mobile/Library/Preferences/com.in8.yourviewing.plist";
static NSString *kALSettingsKey = @"YourViewing";

%ctor {
    @autoreleasepool {
        NSDictionary *switchDict = [NSDictionary dictionaryWithContentsOfFile:k_YourViewing_Plist_Path];
        NSString *switchOnApp = [switchDict objectForKey:kALSettingsKey];
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *appPath = [[NSBundle mainBundle] executablePath];
        
        if ([appPath hasPrefix:@"/var/containers/Bundle/Application/"] || [appPath hasPrefix:@"/Applications/"]) {
            if (switchOnApp.length && bundleIdentifier.length && [switchOnApp isEqualToString:bundleIdentifier]) {
                dlopen("/Library/Application Support/YourView/libyourview.framework/libyourview", RTLD_NOW);
            }
        }
    }
};



