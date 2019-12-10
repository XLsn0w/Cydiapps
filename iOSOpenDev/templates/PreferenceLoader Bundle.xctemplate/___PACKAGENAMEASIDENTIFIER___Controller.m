//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___FILEBASENAME___.h"
#import <Preferences/PSSpecifier.h>

#define kSetting_Example_Name @"NameOfAnExampleSetting"
#define kSetting_Example_Value @"ValueOfAnExampleSetting"

#define kSetting_TemplateVersion_Name @"TemplateVersionExample"
#define kSetting_TemplateVersion_Value @"1.0"

#define kSetting_Text_Name @"TextExample"
#define kSetting_Text_Value @"Go Red Sox!"

#define kUrl_FollowOnTwitter @"https://twitter.com/kokoabim"
#define kUrl_VisitWebSite @"http://iosopendev.com"
#define kUrl_MakeDonation @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=56KLKJLXKM9FS"

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_KeyName_Key @"key"
#define kPrefs_KeyName_Defaults @"defaults"

@implementation ___FILEBASENAMEASIDENTIFIER___

- (id)getValueForSpecifier:(PSSpecifier*)specifier
{
	id value = nil;
	
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];
	
	// get 'value' with code only
	if ([specifierKey isEqual:kSetting_TemplateVersion_Name])
	{
		value = kSetting_TemplateVersion_Value;
	}
	else if ([specifierKey isEqual:kSetting_Example_Name])
	{
		value = kSetting_Example_Value;
	}
	// ...or get 'value' from 'defaults' plist or (optionally as a default value) with code
	else
	{
		// get 'value' from 'defaults' plist (if 'defaults' key and file exists)
		NSMutableString *plistPath = [[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]];
		#if ! __has_feature(objc_arc)
		plistPath = [plistPath autorelease];
		#endif
		if (plistPath)
		{
			NSDictionary *dict = (NSDictionary*)[self initDictionaryWithFile:&plistPath asMutable:NO];
			
			id objectValue = [dict objectForKey:specifierKey];
			
			if (objectValue)
			{
				value = [NSString stringWithFormat:@"%@", objectValue];
				NSLog(@"read key '%@' with value '%@' from plist '%@'", specifierKey, value, plistPath);
			}
			else
			{
				NSLog(@"key '%@' not found in plist '%@'", specifierKey, plistPath);
			}
			
			#if ! __has_feature(objc_arc)
			[dict release];
			#endif
		}
		
		// get default 'value' from code
		if (!value)
		{
			if ([specifierKey isEqual:kSetting_Text_Name])
			{
				value = kSetting_Text_Value;
			}
			else if ([specifierKey isEqual:kSetting_Example_Name])
			{
				value = kSetting_Example_Value;
			}
		}
	}
	
	return value;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
{
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];
	
	// use 'value' with code only
	if ([specifierKey isEqual:kSetting_Example_Name])
	{
		// do something here with 'value'...
	}
	// ...or save 'value' to 'defaults' plist and (optionally) with code
	else
	{
		// save 'value' to 'defaults' plist (if 'defaults' key exists)
		NSMutableString *plistPath = [[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]];
		#if ! __has_feature(objc_arc)
		plistPath = [plistPath autorelease];
		#endif
		if (plistPath)
		{
			NSMutableDictionary *dict = (NSMutableDictionary*)[self initDictionaryWithFile:&plistPath asMutable:YES];
			[dict setObject:value forKey:specifierKey];
			[dict writeToFile:plistPath atomically:YES];
			#if ! __has_feature(objc_arc)
			[dict release];
			#endif

			NSLog(@"saved key '%@' with value '%@' to plist '%@'", specifierKey, value, plistPath);
		}
		
		// use 'value' with code
		if ([specifierKey isEqual:kSetting_Example_Name])
		{
			// do something here with 'value'...
		}
	}
}

- (id)initDictionaryWithFile:(NSMutableString**)plistPath asMutable:(BOOL)asMutable
{
	if ([*plistPath hasPrefix:@"/"])
		*plistPath = [NSString stringWithFormat:@"%@.plist", *plistPath];
	else
		*plistPath = [NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, *plistPath];
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:*plistPath])
		dict = [[class alloc] initWithContentsOfFile:*plistPath];	
	else
		dict = [[class alloc] init];
	
	return dict;
}

- (void)followOnTwitter:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_FollowOnTwitter]];
}

- (void)visitWebSite:(PSSpecifier*)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_VisitWebSite]];
}

- (void)makeDonation:(PSSpecifier *)specifier
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUrl_MakeDonation]];
}

- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"___PACKAGENAMEASIDENTIFIER___" target:self];
		#if ! __has_feature(objc_arc)
		[_specifiers retain];
		#endif
	}
	
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
	}
	
	return self;
}

#if ! __has_feature(objc_arc)
- (void)dealloc
{
	[super dealloc];
}
#endif

@end