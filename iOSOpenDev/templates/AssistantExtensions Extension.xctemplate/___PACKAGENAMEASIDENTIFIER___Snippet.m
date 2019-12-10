//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___FILEBASENAME___.h"

@implementation ___FILEBASENAMEASIDENTIFIER___

- (id)view
{
	return _view;
}

- (id)initWithProperties:(NSDictionary*)props;
{
	// NSLog(@"[___PACKAGENAMEASIDENTIFIER___Snippet initWithProperties:'%@']", props);

	if ((self = [super init]))
	{
		if (![[NSBundle bundleForClass:[self class]] loadNibNamed:@"___PACKAGENAMEASIDENTIFIER___Nib" owner:self options:nil])
		{
			NSLog(@"Failed to load nib file.");
			return NO;
		}
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[props objectForKey:@"link"]]]];
	}
	return self;
}

@end