//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

@interface ___FILEBASENAMEASIDENTIFIER___ : PSListController
{
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;
- (void)setValue:(id)value forSpecifier:(PSSpecifier*)specifier;
- (void)followOnTwitter:(PSSpecifier*)specifier;
- (void)visitWebSite:(PSSpecifier*)specifier;
- (void)makeDonation:(PSSpecifier*)specifier;

@end