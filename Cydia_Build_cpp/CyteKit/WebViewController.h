/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#ifndef CyteKit_WebViewController_H
#define CyteKit_WebViewController_H

#include "CyteKit/ViewController.h"
#include "CyteKit/WebView.h"

#include <UIKit/UIKit.h>
#include <MessageUI/MessageUI.h>

@class IndirectDelegate;

@interface Diversion : NSObject
- (id) initWithFrom:(NSString *)from to:(NSString *)to;
@end

@protocol CyteWebViewControllerDelegate
- (void) retainNetworkActivityIndicator;
- (void) releaseNetworkActivityIndicator;
- (CyteViewController *) pageForURL:(NSURL *)url forExternal:(BOOL)external withReferrer:(NSString *)referrer;
- (void) unloadData;
@end

@interface CyteWebViewController : CyteViewController <
    CyteWebViewDelegate,
    MFMailComposeViewControllerDelegate,
    UIWebViewDelegate
>

+ (void) _initialize;

- (CyteWebView *) webView;
- (CyteWebViewController *) indirect;

- (void) setRequest:(NSURLRequest *)request;
- (NSURLRequest *) request;

- (void) setURL:(NSURL *)url;
- (void) setURL:(NSURL *)url withReferrer:(NSString *)referrer;

- (void) loadURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)policy;
- (void) loadURL:(NSURL *)url;

- (void) loadRequest:(NSURLRequest *)request;
- (bool) isLoading;

- (id) init;

- (id) initWithURL:(NSURL *)url;
- (id) initWithRequest:(NSURLRequest *)request;

- (id) initWithWidth:(float)width;
- (id) initWithWidth:(float)width ofClass:(Class)_class;

+ (void) setApplicationNameForUserAgent:(NSString *)userAgent;
- (NSString *) applicationNameForUserAgent;

- (void) callFunction:(WebScriptObject *)function;
- (void) reloadURLWithCache:(BOOL)cache;

- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;

- (NSURLRequest *) webView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source;
- (NSURLRequest *) webThreadWebView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source;

+ (float) defaultWidth;

- (void) setButtonImage:(NSString *)button withStyle:(NSString *)style toFunction:(id)function;
- (void) setButtonTitle:(NSString *)button withStyle:(NSString *)style toFunction:(id)function;
- (void) setHidesNavigationBar:(bool)value;

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button;
- (void) customButtonClicked;

- (void) applyRightButton;
- (UIBarButtonItem *) rightButton;

- (void) applyLeftButton;
- (UIBarButtonItem *) leftButton;

- (void) removeButton;

- (void) _didStartLoading;
- (void) _didFinishLoading;

- (void) close;

- (void) dispatchEvent:(NSString *)event;

- (void) setViewportWidthOnMainThread:(float)value;

- (void) setScrollAlwaysBounceVertical:(bool)value;
- (void) setScrollIndicatorStyle:(UIScrollViewIndicatorStyle)style;

- (void) registerFrame:(WebFrame *)frame;

+ (void) addDiversion:(Diversion *)diversion;

@end

#endif//CyteKit_WebViewController_H
