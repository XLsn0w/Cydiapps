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

#include "CyteKit/UCPlatform.h"

#include "CyteKit/WebViewTableViewCell.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

@implementation CyteWebViewTableViewCell {
    // XXX: I'm not really the delegate here: fix this!
    _H<CyteWebView, 1> webview_;
}

+ (CyteWebViewTableViewCell *) cellWithRequest:(NSURLRequest *)request {
    CyteWebViewTableViewCell *cell([[[self alloc] initWithRequest:request] autorelease]);
    return cell;
}

- (id) initWithRequest:request {
    if ((self = [super init]) != nil) {
        UIView *view(self);

        webview_ = [[[CyteWebView alloc] initWithFrame:[view bounds]] autorelease];
        [webview_ setDelegate:self];
        [view addSubview:webview_];

        [webview_ setScalesPageToFit:YES];

        UIWebDocumentView *document([webview_ _documentView]);
        WebView *webview([document webView]);
        [webview setShouldUpdateWhileOffscreen:NO];

        if ([document respondsToSelector:@selector(setAllowsMessaging:)])
            [document setAllowsMessaging:YES];
        if ([webview respondsToSelector:@selector(_setAllowsMessaging:)])
            [webview _setAllowsMessaging:YES];

        UIScrollView *scroller([webview_ scrollView]);
        [scroller setScrollingEnabled:NO];
        [scroller setFixedBackgroundPattern:YES];
        [scroller setBackgroundColor:[UIColor clearColor]];

        WebPreferences *preferences([webview preferences]);
        [preferences setCacheModel:WebCacheModelDocumentBrowser];
        [preferences setJavaScriptCanOpenWindowsAutomatically:YES];
        [preferences setOfflineWebApplicationCacheEnabled:YES];

        [webview_ loadRequest:request];

        [webview_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    } return self;
}

- (id) delegate {
    return [webview_ delegate];
}

- (void) setDelegate:(id)delegate {
    [webview_ setDelegate:delegate];
}

@end
