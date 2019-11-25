#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <dlfcn.h>

@interface FLEXManager

+ (instancetype)sharedManager;
- (void)showExplorer;

@end


@interface FLEXLoader: NSObject
@end

@implementation FLEXLoader

+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	static FLEXLoader *loader;
	dispatch_once(&onceToken, ^{
		loader = [[FLEXLoader alloc] init];
	});	

	return loader;
}

- (void)show {
	[[objc_getClass("FLEXManager") sharedManager] showExplorer];
}

@end

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSDictionary *pref = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.swiftyper.flexloader.plist"];
	NSString *dylibPath = @"/Library/Application Support/FLEXLoader/libFLEX.dylib";

	if (![[NSFileManager defaultManager] fileExistsAtPath:dylibPath]) {
		NSLog(@"FLEXLoader dylib file not found: %@", dylibPath);
		return;
	} 

	NSString *keyPath = [NSString stringWithFormat:@"FLEXLoaderEnabled-%@", [[NSBundle mainBundle] bundleIdentifier]];
	if ([[pref objectForKey:keyPath] boolValue]) {
		void *handle = dlopen([dylibPath UTF8String], RTLD_NOW);
		if (handle == NULL) {
			char *error = dlerror();
			NSLog(@"Load FLEXLoader dylib fail: %s", error);
			return;
		} 

		[[NSNotificationCenter defaultCenter] addObserver:[FLEXLoader sharedInstance]
										   selector:@selector(show)
											   name:UIApplicationDidBecomeActiveNotification
											 object:nil];
	}	

	[pool drain];
}
