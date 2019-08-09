#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSBundleController.h>
#import <Preferences/PSTableCell.h>
#import <substrate.h>

#import "prefs.h"

#define DEBUG_TAG "libprefs"
#import "debug.h"

/* {{{ Imports (Preferences.framework) */
extern "C" NSArray* SpecifiersFromPlist(NSDictionary* plist,
					PSSpecifier* prevSpec,
					id target,
					NSString* plistName,
					NSBundle* curBundle,
					NSString** pTitle,
					NSString** pSpecifierID,
					PSListController* callerList,
					NSMutableArray** pBundleControllers);


extern NSString *const PSBundlePathKey;
extern NSString *const PSLazilyLoadedBundleKey;
extern NSString *const PSBundleIsControllerKey;
extern NSString *const PSActionKey;
extern NSString *const PSTitleKey;

// Weak (3.2+, dlsym)
static NSString **pPSFooterTextGroupKey = NULL;
static NSString **pPSStaticTextGroupKey = NULL;
/* }}} */

/* {{{ PSSpecifier 3.2 Additions */
@interface PSSpecifier (OS32)
- (Class)detailControllerClass;
@end
/* }}} */

/* {{{ PSViewController 3.2 Additions */
@interface PSViewController (OS32)
- (void)setSpecifier:(PSSpecifier *)specifier;
@end
/* }}} */

/* {{{ Prototypes */
static NSArray *generateErrorSpecifiersWithText(NSString *errorText);
/* }}} */

/* {{{ Constants */
static NSString *const PLBundleKey = @"pl_bundle";
NSString *const PLFilterKey = @"pl_filter";
static NSString *const PLAlternatePlistNameKey = @"pl_alt_plist_name";
/* }}} */

/* {{{ Locals */
static BOOL _Firmware_lt_60 = NO;
/* }}} */

/* {{{ Preferences Controllers */
@implementation PLCustomListController
- (id)bundle {
	return [[self specifier] preferenceLoaderBundle];
}

- (id)specifiers {
	if(!_specifiers) {
		PLLog(@"loading specifiers for a custom bundle.");
		PSSpecifier *specifier = [self specifier];
		if(!specifier) {
			NSString *errorText = @"There appears to have been an error restoring these preferences!";
			return _specifiers = [[NSArray alloc] initWithArray:generateErrorSpecifiersWithText(errorText)];
		}
		NSString *alternatePlistName = [specifier propertyForKey:PLAlternatePlistNameKey];
		if(alternatePlistName)
			_specifiers = [[self loadSpecifiersFromPlistName:alternatePlistName target:self] retain];
		else
			_specifiers = [super specifiers];
		if(!_specifiers || [_specifiers count] == 0) {
			[_specifiers release];
			NSString *errorText = @"There appears to be an error with these preferences!";
			_specifiers = [[NSArray alloc] initWithArray:generateErrorSpecifiersWithText(errorText)];
		} else {
			if([self respondsToSelector:@selector(setTitle:)]) {
				[self setTitle:specifier.name];
			}
			NSMutableArray *removals = [NSMutableArray array];
			for(PSSpecifier *spec in _specifiers) {
				if(MSHookIvar<int>(spec, "cellType") == PSLinkCell && ![spec propertyForKey:PSBundlePathKey]) {
					MSHookIvar<Class>(spec, "detailControllerClass") = [self class];
					[spec setProperty:[[self specifier] propertyForKey:PLBundleKey] forKey:PLBundleKey];
				}

				if(![PSSpecifier environmentPassesPreferenceLoaderFilter:[spec propertyForKey:PLFilterKey]])
					[removals addObject:spec];

				if(removals.count > 0) {
					NSMutableArray *newSpecifiers = [_specifiers mutableCopy];
					[_specifiers release];
					[newSpecifiers removeObjectsInArray:removals];
					_specifiers = newSpecifiers;
				}
			}
		}
	}
	return _specifiers;
}

- (id)navigationTitle {
	return self.specifier.name;
}

@end

@implementation PLLocalizedListController
- (id)navigationTitle {
	NSString *original = [super navigationTitle];
	return [[self bundle] localizedStringForKey:original value:original table:nil];
}

- (id)specifiers {
	if(!_specifiers) {
		PLLog(@"Localizing specifiers for a localized bundle.");
		_specifiers = [super specifiers];
		for(PSSpecifier *spec in _specifiers) {
			if([spec name]) [spec setName:[[self bundle] localizedStringForKey:[spec name] value:[spec name] table:nil]];
			if([spec titleDictionary]) {
				NSMutableDictionary *newTitles = [NSMutableDictionary dictionary];
				for(NSString *key in [spec titleDictionary]) {
					NSString *value = [[spec titleDictionary] objectForKey:key];
					[newTitles setObject:[[self bundle] localizedStringForKey:value value:value table:nil] forKey:key];
				}
				[spec setTitleDictionary:newTitles];
			}
			if([spec shortTitleDictionary]) {
				NSMutableDictionary *newTitles = [NSMutableDictionary dictionary];
				for(NSString *key in [spec shortTitleDictionary]) {
					NSString *value = [[spec shortTitleDictionary] objectForKey:key];
					[newTitles setObject:[[self bundle] localizedStringForKey:value value:value table:nil] forKey:key];
				}
				[spec setShortTitleDictionary:newTitles];
			}
			static NSString *localizableKeys[] = { @"headerDetailText", @"placeholder", @"staticTextMessage" };
			for (size_t i = 0; i < sizeof(localizableKeys) / sizeof(NSString *); i++) {
				NSString *value = [spec propertyForKey:localizableKeys[i]];
				if(value)
					[spec setProperty:[[self bundle] localizedStringForKey:value value:value table:nil] forKey:localizableKeys[i]];
			}
			if(pPSFooterTextGroupKey) {
				NSString *value = [spec propertyForKey:*pPSFooterTextGroupKey];
				if(value)
					[spec setProperty:[[self bundle] localizedStringForKey:value value:value table:nil] forKey:*pPSFooterTextGroupKey];
			}
		}
	}
	return _specifiers;
}
@end

@interface PLFailedBundleListController: PSListController { }
@end
@implementation PLFailedBundleListController
- (id)navigationTitle {
	return @"Error";
}

- (id)specifiers {
	if(!_specifiers) {
		PLLog(@"Generating error specifiers for a failed bundle :(");
		NSString *const errorText = [NSString stringWithFormat:@"There was an error loading the preference bundle for %@.", [[self specifier] name]];
		_specifiers = [[NSArray alloc] initWithArray:generateErrorSpecifiersWithText(errorText)];
	}
	return _specifiers;
}
@end
/* }}} */

/* {{{ Helper Functions */
static NSArray *generateErrorSpecifiersWithText(NSString *errorText) {
	NSMutableArray *errorSpecifiers = [NSMutableArray array];
	if(pPSFooterTextGroupKey) {
		PSSpecifier *spec = [PSSpecifier emptyGroupSpecifier];
		[spec setProperty:errorText forKey:*pPSFooterTextGroupKey];
		[errorSpecifiers addObject:spec];
	} else {
		if(pPSStaticTextGroupKey) {
			PSSpecifier *spec = [PSSpecifier emptyGroupSpecifier];
			[spec setProperty:[NSNumber numberWithBool:YES] forKey:*pPSStaticTextGroupKey];
			[errorSpecifiers addObject:spec];
			spec = [PSSpecifier preferenceSpecifierNamed:errorText target:nil set:nil get:nil detail:nil cell:[PSTableCell cellTypeFromString:@"PSTitleValueCell"] edit:nil];
			[errorSpecifiers addObject:spec];
		}
	}
	return errorSpecifiers;
}

@implementation PSSpecifier (libprefs)
+ (BOOL)environmentPassesPreferenceLoaderFilter:(NSDictionary *)filter {
	PLLog(@"Checking filter %@", filter);

	if(!filter) return YES;
	bool valid = YES;

	NSArray *coreFoundationVersion = [filter objectForKey:@"CoreFoundationVersion"];
	if(coreFoundationVersion && coreFoundationVersion.count > 0) {
		NSNumber *lowerBound = [coreFoundationVersion objectAtIndex:0];
		NSNumber *upperBound = coreFoundationVersion.count > 1 ? [coreFoundationVersion objectAtIndex:1] : nil;
		PLLog(@"%@ <= CF Version (%f) < %@", lowerBound, kCFCoreFoundationVersionNumber, upperBound);
		valid = valid && (kCFCoreFoundationVersionNumber >= lowerBound.floatValue);

		if(upperBound)
			valid = valid && (kCFCoreFoundationVersionNumber < upperBound.floatValue);
	}
	PLLog(valid ? @"Filter matched" : @"Filter did not match");
	return valid;
}

- (NSBundle *)preferenceLoaderBundle {
	return [self propertyForKey:PLBundleKey];
}

@end
/* }}} */

/* {{{ Hooks */
static void pl_loadFailedBundle(NSString *bundlePath, PSSpecifier *specifier) {
	PLLog(@"lazyLoadBundle:%@ (bundle path %@) failed.", specifier, bundlePath);
	NSLog(@"Failed to load PreferenceBundle at %@.", bundlePath);
	MSHookIvar<Class>(specifier, "detailControllerClass") = [PLFailedBundleListController class];
	[specifier removePropertyForKey:PSBundleIsControllerKey];
	[specifier removePropertyForKey:PSActionKey];
	[specifier removePropertyForKey:PSBundlePathKey];
	[specifier removePropertyForKey:PSLazilyLoadedBundleKey];
}

static void pl_lazyLoadBundleCore(id self, SEL _cmd, PSSpecifier *specifier, void(*_orig)(id, SEL, PSSpecifier *)) {
	NSString *bundlePath = [[specifier propertyForKey:PSLazilyLoadedBundleKey] retain];
	PLLog(@"In pl_lazyLoadBundleCore for %@ (%s), specifier %@", self, _cmd, specifier);
	PLLog(@"%%orig is %p.", _orig);

	_orig(self, _cmd, specifier); // NB: This removes the PSLazilyLoadedBundleKey property.
	if(![[NSBundle bundleWithPath:bundlePath] isLoaded]) {
		pl_loadFailedBundle(bundlePath, specifier);
	}
	[bundlePath release];
}

%group Firmware_lt_60
%hook PrefsRootController
- (void)lazyLoadBundle:(PSSpecifier *)specifier {
	pl_lazyLoadBundleCore(self, _cmd, specifier, &%orig);

}
%end
%end

%hook PSListController
%group Firmware_ge_60
- (void)lazyLoadBundle:(PSSpecifier *)specifier {
	pl_lazyLoadBundleCore(self, _cmd, specifier, &%orig);
}
%end

%new
- (PSViewController *)controllerForSpecifier:(PSSpecifier *)specifier
{
	%log();
	Class detailClass = [specifier respondsToSelector:@selector(detailControllerClass)] ? [specifier detailControllerClass] : MSHookIvar<Class>(specifier, "detailControllerClass");
	if (!detailClass)
		detailClass = [PLCustomListController class];
	if (![detailClass isSubclassOfClass:[PSViewController class]])
		return nil;
	id result = [detailClass alloc];
	if ([result respondsToSelector:@selector(initForContentSize:)])
		result = [result initForContentSize:[[self view] bounds].size];
	else
		result = [result init];
	[result setRootController:self.rootController];
	[result setParentController:self];
	if ([result respondsToSelector:@selector(setSpecifier:)])
		[result setSpecifier:specifier];
	else if ([result isKindOfClass:[PSListController class]]) {
		NSArray *&_specifierIvar = MSHookIvar<NSArray *>(result, "_specifier");
		[_specifierIvar release];
		_specifierIvar = [specifier retain];
	}
	return [result autorelease];
}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target {
	NSArray *result = %orig();
	if([result count] > 0)
		return result;

	NSDictionary *properties = self.specifier.properties;
	if(!properties)
		return nil;

	PLLog(@"Loading specifiers from PSListController's specifier's properties.");
	NSArray *&bundleControllers = MSHookIvar<NSArray *>(self, "_bundleControllers");
	NSString *title = nil;
	NSString *specifierID = nil;
	result = SpecifiersFromPlist(properties, [self specifier], target, plistName, [self bundle], &title, &specifierID, self, &bundleControllers);

	if(title)
		[self setTitle:title];

	if(specifierID)
		[self setSpecifierID:specifierID];

	return result;
}
%end

%hook NSBundle
+ (NSBundle *)bundleWithPath:(NSString *)path {
	NSString *newPath = nil;
	NSRange sysRange = [path rangeOfString:@"/System/Library/PreferenceBundles" options:0];
	if(sysRange.location != NSNotFound) {
		newPath = [path stringByReplacingCharactersInRange:sysRange withString:@"/Library/PreferenceBundles"];
	}
	if(newPath && [[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
		// /Library/PreferenceBundles will override /System/Library/PreferenceBundles.
		path = newPath;
	}
	return %orig;
}
%end
/* }}} */

@implementation PSListController (libprefs)

- (NSArray *)specifiersFromEntry:(NSDictionary *)entry sourcePreferenceLoaderBundlePath:(NSString *)sourceBundlePath title:(NSString *)title {
	NSDictionary *specifierPlist = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:entry, nil], @"items", nil];

	BOOL isBundle = [entry objectForKey:@"bundle"] != nil;
	BOOL isLocalizedBundle = ![[sourceBundlePath lastPathComponent] isEqualToString:@"Preferences"];

	NSBundle *prefBundle;
	NSString *bundleName = [entry objectForKey:@"bundle"];
	NSString *bundlePath = [entry objectForKey:@"bundlePath"];

	if(isBundle) {
		// Second Try (bundlePath key failed)
		if(![[NSFileManager defaultManager] fileExistsAtPath:bundlePath])
			bundlePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/%@.bundle", bundleName];

		// Third Try (/Library failed)
		if(![[NSFileManager defaultManager] fileExistsAtPath:bundlePath])
			bundlePath = [NSString stringWithFormat:@"/System/Library/PreferenceBundles/%@.bundle", bundleName];

		// Really? (/System/Library failed...)
		if(![[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
			NSLog(@"Discarding specifier for missing isBundle bundle %@.", bundleName);
			return nil;
		}
		prefBundle = [NSBundle bundleWithPath:bundlePath];
		PLLog(@"is a bundle: %@!", prefBundle);
	} else {
		prefBundle = [NSBundle bundleWithPath:sourceBundlePath];
		PLLog(@"is NOT a bundle, so we're giving it %@!", prefBundle);
	}

	PLLog(@"loading specifiers!");
	NSArray *&bundleControllers = MSHookIvar<NSArray *>(self, "_bundleControllers");
	NSArray *specs = SpecifiersFromPlist(specifierPlist, nil, _Firmware_lt_60 ? [self rootController] : self, title, prefBundle, NULL, NULL, (PSListController*)self, &bundleControllers);
	PLLog(@"loaded specifiers!");

	if([specs count] == 0) return nil;
	PLLog(@"It's confirmed! There are Specifiers here, Captain!");

	if(isBundle) {
		 // Only set lazy-bundle for isController specifiers.
		if([[entry objectForKey:@"isController"] boolValue]) {
			for(PSSpecifier *specifier in specs) {
				[specifier setProperty:bundlePath forKey:PSLazilyLoadedBundleKey];
				[specifier setProperty:[NSBundle bundleWithPath:sourceBundlePath] forKey:PLBundleKey];
				if(!specifier.name) {
					specifier.name = title;
				}
			}
		}
	} else {
		// There really should only be one specifier.
		PSSpecifier *specifier = [specs objectAtIndex:0];
		MSHookIvar<Class>(specifier, "detailControllerClass") = isLocalizedBundle ? [PLLocalizedListController class] : [PLCustomListController class];
		[specifier setProperty:prefBundle forKey:PLBundleKey];

		if(![[specifier propertyForKey:PSTitleKey] isEqualToString:title]) {
			[specifier setProperty:title forKey:PLAlternatePlistNameKey];
			if(!specifier.name) {
				specifier.name = title;
			}
		}
	}

	return specs;
}

@end

%ctor {
	_Firmware_lt_60 = kCFCoreFoundationVersionNumber < 793.00;
	%init;

	if(_Firmware_lt_60) {
		%init(Firmware_lt_60);
	} else {
		%init(Firmware_ge_60);
	}

	void *preferencesHandle = dlopen("/System/Library/PrivateFrameworks/Preferences.framework/Preferences", RTLD_LAZY | RTLD_NOLOAD);
	if(preferencesHandle) {
		pPSFooterTextGroupKey = (NSString **)dlsym(preferencesHandle, "PSFooterTextGroupKey");
		pPSStaticTextGroupKey = (NSString **)dlsym(preferencesHandle, "PSStaticTextGroupKey");
		dlclose(preferencesHandle);
	}
}
