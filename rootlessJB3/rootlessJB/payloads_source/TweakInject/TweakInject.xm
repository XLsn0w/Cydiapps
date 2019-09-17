#import <dlfcn.h>
#import <objc/runtime.h>
#import <stdlib.h>
#import <stdio.h>
#import <unistd.h>
#import <pthread.h>
#import <sys/stat.h>
#import <sys/types.h>
#import <sys/mman.h>

#import "fishhook.h"

#define TWEAKINJECTDEBUG 1

#ifndef TWEAKINJECTDEBUG
#define printf(str, ...)
#define NSLog(str, ...)
#endif

#define dylibDir @"/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries"

NSArray *sbinjectGenerateDylibList() {
    NSString *processName = [[NSProcessInfo processInfo] processName];
    // launchctl, amfid you are special cases
    if ([processName isEqualToString:@"launchctl"]) {
        return nil;
    }
    // Create an array containing all the filenames in dylibDir (/opt/simject)
    NSError *e = nil;
    NSArray *dylibDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dylibDir error:&e];
    if (e) {
        return nil;
    }
    // Read current bundle identifier
    //NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    // We're only interested in the plist files
    NSArray *plists = [dylibDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", @"plist"]];
    // Create an empty mutable array that will contain a list of dylib paths to be injected into the target process
    NSMutableArray *dylibsToInject = [NSMutableArray array];
    // Loop through the list of plists
    for (NSString *plist in plists) {
        // We'll want to deal with absolute paths, so append the filename to dylibDir
        NSString *plistPath = [dylibDir stringByAppendingPathComponent:plist];
        NSDictionary *filter = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        // This boolean indicates whether or not the dylib has already been injected
        BOOL isInjected = NO;
        // If supported iOS versions are specified within the plist, we check those first
        NSArray *supportedVersions = filter[@"CoreFoundationVersion"];
        if (supportedVersions) {
            if (supportedVersions.count != 1 && supportedVersions.count != 2) {
                continue; // Supported versions are in the wrong format, we should skip
            }
            if (supportedVersions.count == 1 && [supportedVersions[0] doubleValue] > kCFCoreFoundationVersionNumber) {
                continue; // Doesn't meet lower bound
            }
            if (supportedVersions.count == 2 && ([supportedVersions[0] doubleValue] > kCFCoreFoundationVersionNumber || [supportedVersions[1] doubleValue] <= kCFCoreFoundationVersionNumber)) {
                continue; // Outside bounds
            }
        }
        // Decide whether or not to load the dylib based on the Bundles values
        for (NSString *entry in filter[@"Filter"][@"Bundles"]) {
            // Check to see whether or not this bundle is actually loaded in this application or not
            if (!CFBundleGetBundleWithIdentifier((CFStringRef)entry)) {
                // If not, skip it
                continue;
            }
            [dylibsToInject addObject:[[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"]];
            isInjected = YES;
            break;
        }
        if (!isInjected) {
            // Decide whether or not to load the dylib based on the Executables values
            for (NSString *process in filter[@"Filter"][@"Executables"]) {
                if ([process isEqualToString:processName]) {
                    [dylibsToInject addObject:[[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"]];
                    isInjected = YES;
                    break;
                }
            }
        }
        if (!isInjected) {
            // Decide whether or not to load the dylib based on the Classes values
            for (NSString *clazz in filter[@"Filter"][@"Classes"]) {
                // Also check if this class is loaded in this application or not
                if (!NSClassFromString(clazz)) {
                    // This class couldn't be loaded, skip
                    continue;
                }
                // It's fine to add this dylib at this point
                [dylibsToInject addObject:[[plistPath stringByDeletingPathExtension] stringByAppendingString:@".dylib"]];
                isInjected = YES;
                break;
            }
        }
    }
    [dylibsToInject sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return dylibsToInject;
}

void SpringBoardSigHandler(int signo, siginfo_t *info, void *uap){
    NSLog(@"Received signal %d", signo);

    FILE *f = fopen("/var/mobile/.sbinjectSafeMode", "w");
    fprintf(f, "Hello World\n");
    fclose(f);

    raise(signo);
}

int file_exist(char *filename) {
    struct stat buffer;
    int r = stat(filename, &buffer);
    return (r == 0);
}

@interface SpringBoard : UIApplication
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

%group SafeMode
%hook SBLockScreenViewController
-(void)finishUIUnlockFromSource:(int)source {
    %orig;
    /* if u think UIAlertControllers are better ur an ignorant
     hooray for UIAlertViews */
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Safe Mode" message:@"Oops! SpringBoard just crashed. Neither Substitute nor Tweak Injector caused this. Do you want to respring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
    [alert show];
    [alert release];
}
%new
- (void)alertView:(UIAlertView *)alertView cickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        exit(0);
    }
}
%end

%hook SBDashBoardViewController
-(void)finishUIUnlockFromSource:(int)source {
    %orig;
    /* if u think UIAlertControllers are better ur an ignorant
     hooray for UIAlertViews */
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Safe Mode" message:@"Oops! SpringBoard just crashed. Neither Substitute nor Tweak Injector caused this. Do you want to respring?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
    [alert show];
    [alert release];
}
%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        exit(0);
    }
}
%end
%end

/*%group mmap_patch
%hookf(void *, mmap, void *addr, size_t length, int prot, int flags, int fd, off_t offset) {
    void *ret = %orig;
    if (ret == MAP_FAILED && (prot & 4)) {
        NSLog(@"First failed, mmap: %p", ret);
        ret = %orig;
        NSLog(@"Second mmap: %p", ret);
    }
    return ret;
}
%end*/

//%group dlopen_patch
/*%hookf(void *, dlopen, const char *filename, int flag) {
    void *ret = %orig;
    if (ret == NULL) {
        if (strstr(filename, "/var/containers/Bundle") && strstr(filename, ".dylib")) {
            // a somewhat way to wait for jbd to patch dylib
            int tries = 5;
            while (tries-- > 0) {
                ret = %orig;
                if (ret) return ret;
            }
        }
    }
    return ret;
}
%end*/

typedef void *(*dlopen_t)(const char *filename, int flag);
dlopen_t old_dlopen;

void *patched_dlopen(const char *filename, int flag) {
    void *ret = old_dlopen(filename, flag);
    if (ret == NULL) {
        if (strstr(filename, "/var/containers/Bundle") && strstr(filename, ".dylib")) {
            // a somewhat way to wait for jbd to patch dylib
            int tries = 5;
            while (tries-- > 0) {
                ret = old_dlopen(filename, flag);
                if (ret) return ret;
            }
        }
    }
    return ret;
}

void dlopen_patch() {
    struct rebinding rebindings[] = {
        {"dlopen", (void *)patched_dlopen, (void **)&old_dlopen}
    };
    rebind_symbols(rebindings, 1);
}

BOOL safeMode = false;

__attribute__ ((constructor))
static void ctor(void) {
    @autoreleasepool {
        
        //%init(mmap_patch);
        dlopen_patch(); // mmap patch triggers some weird behavior;
                             // maybe do a low level dyld patch?
                             // well idk if I'm sure how to do that
        
        if (NSBundle.mainBundle.bundleIdentifier == nil || ![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"org.coolstar.SafeMode"]){
            safeMode = false;
            NSString *processName = [[NSProcessInfo processInfo] processName];
            if ([processName isEqualToString:@"backboardd"] || [NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
                struct sigaction action;
                memset(&action, 0, sizeof(action));
                action.sa_sigaction = &SpringBoardSigHandler;
                action.sa_flags = SA_SIGINFO | SA_RESETHAND;
                sigemptyset(&action.sa_mask);

                sigaction(SIGQUIT, &action, NULL);
                sigaction(SIGILL, &action, NULL);
                sigaction(SIGTRAP, &action, NULL);
                sigaction(SIGABRT, &action, NULL);
                sigaction(SIGEMT, &action, NULL);
                sigaction(SIGFPE, &action, NULL);
                sigaction(SIGBUS, &action, NULL);
                sigaction(SIGSEGV, &action, NULL);
                sigaction(SIGSYS, &action, NULL);

                if (file_exist("/var/mobile/.sbinjectSafeMode")){
                    safeMode = true;
                    if ([NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]){
                        unlink("/var/mobile/.sbinjectSafeMode");
                        NSLog(@"Entering Safe Mode!");
                        %init(SafeMode);
                    }
                }
            }

            if (!safeMode) {
                for (NSString *dylib in sbinjectGenerateDylibList()) {
                    NSLog(@"Injecting %@ into %@", dylib, NSBundle.mainBundle.bundleIdentifier);
                    void *dl = dlopen([dylib UTF8String], RTLD_LAZY | RTLD_GLOBAL);

                    if (dl == NULL) {
                        NSLog(@"Injection failed: '%s'", dlerror());
                    }
                }
            }
        }
    }
}
