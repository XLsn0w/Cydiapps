#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <stdio.h>
#import <objc/runtime.h>

@interface LSApplicationWorkspace : NSObject
+ (id) defaultWorkspace;
- (BOOL) registerApplication:(id)application;
- (BOOL) unregisterApplication:(id)application;
- (BOOL) invalidateIconCache:(id)bundle;
- (BOOL) registerApplicationDictionary:(id)application;
- (BOOL) installApplication:(id)application withOptions:(id)options;
- (BOOL) _LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)system internal:(BOOL)internal user:(BOOL)user;
@end

int main(int argc, char **argv, char **envp) {
    void *handle = dlopen("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices", 0);
    if (!handle) {
        printf("[-] Failed to load MCS framework\n");
        return -1;
    }
    
    LSApplicationWorkspace *workspace = [objc_getClass("LSApplicationWorkspace") defaultWorkspace];
    
    if ([workspace respondsToSelector:@selector(installApplication:withOptions:)]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *appPath = @"/var/containers/Bundle/tweaksupport/Applications";
        NSError *error;
        
        if (![fileManager fileExistsAtPath:appPath]) {
            printf("[-] App directory does not exist\n");
            return -1;
        }
        
        NSArray *apps = [fileManager contentsOfDirectoryAtPath:appPath error:&error];
        if (error) {
            printf("[-] Error: %s\n", [[error localizedDescription] UTF8String]);
            return -1;
        }
        
        BOOL isDir = NO;
        
        for (NSString *app in apps) {
            app = [@"/var/containers/Bundle/tweaksupport/Applications" stringByAppendingPathComponent:app];
            
            [fileManager fileExistsAtPath:app isDirectory:&isDir];
            
            if (isDir && [app hasSuffix:@".app"]) {
                NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[app stringByAppendingPathComponent:@"Info.plist"]];
                
                if (!infoPlist) {
                    printf("[-] Can't open Info.plist of %s\n", [app UTF8String]);
                    return -1;
                }
                
                NSString *bundleID = [infoPlist objectForKey:@"CFBundleIdentifier"];
                printf("[*] Installing app %s\n", [bundleID UTF8String]);
                
                if (![workspace installApplication:[NSURL URLWithString:app] withOptions:[NSDictionary dictionaryWithObject:bundleID forKey:@"CFBundleIdentifier"]]) {
                    printf("[-] Can't install app %s\n", [app UTF8String]);
                }
            }
        }
        return 0;
    }
    printf("[-] Failed to install apps. iOS version not supported\n");
    return 1;
}

