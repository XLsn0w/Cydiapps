//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___FILEBASENAME___.h"
#import "___PROJECTNAMEASIDENTIFIER___Commands.h"
#import "___PROJECTNAMEASIDENTIFIER___Snippet.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

-(id)initWithSystem:(id<SESystem>)system
{
	if ((self = [super init]))
	{
		[system registerCommand:[___PROJECTNAMEASIDENTIFIER___Commands class]];
		[system registerSnippet:[___PROJECTNAMEASIDENTIFIER___Snippet class]];
	}
	return self;
}

-(NSString*)author
{
	return @"___FULLUSERNAME___";
}

-(NSString*)name
{
	return @"___PROJECTNAME___";
}

-(NSString*)description
{
	return @"Created using the iOSOpenDev Xcode template for building an Assistant Extension";
}

-(NSString*)website
{
	return @"http://www.iOSOpenDev.com";
}

-(NSString*)versionRequirement
{
	return @"1.0.1";
}

@end