#import <Preferences/Preferences.h>
#import <substrate.h>

#import "prefs.h"

#define DEBUG_TAG "PreferenceLoader"
#import "debug.h"

/* {{{ Imports (Preferences.framework) */
// Weak (3.2+, dlsym)
static NSString **pPSTableCellUseEtchedAppearanceKey = NULL;
/* }}} */

/* {{{ UIDevice 3.2 Additions */
@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end
/* }}} */

/* {{{ Locals */
static BOOL _Firmware_lt_60 = NO;
/* }}} */

%hook PrefsListController
static NSMutableArray *_loadedSpecifiers = nil;
static int _extraPrefsGroupSectionID = 0;

/* {{{ iPad Hooks */
%group iPad
- (NSString *)tableView:(id)view titleForHeaderInSection:(int)section {
	if([_loadedSpecifiers count] == 0) return %orig;
	if(section == _extraPrefsGroupSectionID) return _Firmware_lt_60 ? @"Extensions" : NULL;
	return %orig;
}

- (float)tableView:(id)view heightForHeaderInSection:(int)section {
	if([_loadedSpecifiers count] == 0) return %orig;
	if(section == _extraPrefsGroupSectionID) return _Firmware_lt_60 ? 22.0f : 10.f;
	return %orig;
}
%end
/* }}} */

static NSInteger PSSpecifierSort(PSSpecifier *a1, PSSpecifier *a2, void *context) {
	NSString *string1 = [a1 name];
	NSString *string2 = [a2 name];
	return [string1 localizedCaseInsensitiveCompare:string2];
}

- (id)specifiers {
	bool first = (MSHookIvar<id>(self, "_specifiers") == nil);
	if(first) {
		PLLog(@"initial invocation for -specifiers");
		%orig;
		[_loadedSpecifiers release];
		_loadedSpecifiers = [[NSMutableArray alloc] init];
		NSArray *subpaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:@"/Library/PreferenceLoader/Preferences" error:NULL];
		for(NSString *item in subpaths) {
			if(![[item pathExtension] isEqualToString:@"plist"]) continue;
			PLLog(@"processing %@", item);
			NSString *fullPath = [NSString stringWithFormat:@"/Library/PreferenceLoader/Preferences/%@", item];
			NSDictionary *plPlist = [NSDictionary dictionaryWithContentsOfFile:fullPath];
			if(![PSSpecifier environmentPassesPreferenceLoaderFilter:[plPlist objectForKey:@"filter"] ?: [plPlist objectForKey:PLFilterKey]]) continue;

			NSDictionary *entry = [plPlist objectForKey:@"entry"];
			if(!entry) continue;
			PLLog(@"found an entry key for %@!", item);

			if(![PSSpecifier environmentPassesPreferenceLoaderFilter:[entry objectForKey:PLFilterKey]]) continue;

			NSArray *specs = [self specifiersFromEntry:entry sourcePreferenceLoaderBundlePath:[fullPath stringByDeletingLastPathComponent] title:[[item lastPathComponent] stringByDeletingPathExtension]];
			if(!specs) continue;

			// But it's possible for there to be more than one with an isController == 0 (PSBundleController) bundle.
			// so, set all the specifiers to etched mode (if necessary).
			if(pPSTableCellUseEtchedAppearanceKey && [UIDevice instancesRespondToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])
				for(PSSpecifier *specifier in specs) {
					[specifier setProperty:[NSNumber numberWithBool:1] forKey:*pPSTableCellUseEtchedAppearanceKey];
				}

			PLLog(@"appending to the array!");
			[_loadedSpecifiers addObjectsFromArray:specs];
		}

		[_loadedSpecifiers sortUsingFunction:&PSSpecifierSort context:NULL];

		if([_loadedSpecifiers count] > 0) {
			PLLog(@"so we gots us some specifiers! that's awesome! let's add them to the list...");
			PSSpecifier *groupSpecifier = [PSSpecifier groupSpecifierWithName:_Firmware_lt_60 ? @"Extensions" : nil];
			[_loadedSpecifiers insertObject:groupSpecifier atIndex:0];
			NSMutableArray *_specifiers = MSHookIvar<NSMutableArray *>(self, "_specifiers");
			int group, row;
			int firstindex;
			if ([self getGroup:&group row:&row ofSpecifierID:_Firmware_lt_60 ? @"General" : @"TWITTER"]) {
				firstindex = [self indexOfGroup:group] + [[self specifiersInGroup:group] count];
				PLLog(@"Adding to the end of group %d at index %d", group, firstindex);
			} else {
				firstindex = [_specifiers count];
				PLLog(@"Adding to the end of entire list");
			}
			NSIndexSet *indices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstindex, [_loadedSpecifiers count])];
			[_specifiers insertObjects:_loadedSpecifiers atIndexes:indices];
			PLLog(@"getting group index");
			NSUInteger groupIndex = 0;
			for(PSSpecifier *spec in _specifiers) {
				if(MSHookIvar<int>(spec, "cellType") != PSGroupCell) continue;
				if(spec == groupSpecifier) break;
				++groupIndex;
			}
			_extraPrefsGroupSectionID = groupIndex;
			PLLog(@"group index is %d", _extraPrefsGroupSectionID);
		}
	}
	return MSHookIvar<id>(self, "_specifiers");
}
%end

%ctor {
	%init();

	_Firmware_lt_60 = kCFCoreFoundationVersionNumber < 793.00;
	if([UIDevice instancesRespondToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])
		%init(iPad);

	void *preferencesHandle = dlopen("/System/Library/PrivateFrameworks/Preferences.framework/Preferences", RTLD_LAZY | RTLD_NOLOAD);
	if(preferencesHandle) {
		pPSTableCellUseEtchedAppearanceKey = (NSString **)dlsym(preferencesHandle, "PSTableCellUseEtchedAppearanceKey");
		dlclose(preferencesHandle);
	}
}
