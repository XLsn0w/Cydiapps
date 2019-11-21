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

#include "CyteKit/dispatchEvent.h"
#include "CyteKit/WebView.h"

#include "Substrate.hpp"

#include "iPhonePrivate.h"

// CYWebPolicyDecision* {{{
@interface CYWebPolicyDecisionMediator : NSObject <
    WebPolicyDecisionListener
> {
    id<WebPolicyDecisionListener> listener_;
    CYWebPolicyDecision decision_;
}

- (id) initWithListener:(id<WebPolicyDecisionListener>)listener;

- (CYWebPolicyDecision) decision;
- (bool) decided;
- (bool) decide;

@end

@implementation CYWebPolicyDecisionMediator

- (id) initWithListener:(id<WebPolicyDecisionListener>)listener {
    if ((self = [super init]) != nil) {
        listener_ = listener;
    } return self;
}

- (CYWebPolicyDecision) decision {
    return decision_;
}

- (bool) decided {
    return decision_ != CYWebPolicyDecisionUnknown;
}

- (bool) decide {
    switch (decision_) {
        case CYWebPolicyDecisionUnknown:
        default:
            NSLog(@"CYWebPolicyDecisionUnknown");
            return false;

        case CYWebPolicyDecisionDownload: [listener_ download]; break;
        case CYWebPolicyDecisionIgnore: [listener_ ignore]; break;
        case CYWebPolicyDecisionUse: [listener_ use]; break;
    }

    return true;
}

- (void) download {
    decision_ = CYWebPolicyDecisionDownload;
}

- (void) ignore {
    decision_ = CYWebPolicyDecisionIgnore;
}

- (void) use {
    decision_ = CYWebPolicyDecisionUse;
}

@end
// }}}

@implementation CyteWebView : UIWebView {
}

#if ShowInternals
#include "CyteKit/UCInternal.h"
#endif

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]) != nil) {
    } return self;
}

- (void) dealloc {
    if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iPhoneOS_3_0) {
        UIWebViewInternal *&_internal(MSHookIvar<UIWebViewInternal *>(self, "_internal"));
        if (&_internal != NULL) {
            UIWebViewWebViewDelegate *&webViewDelegate(MSHookIvar<UIWebViewWebViewDelegate *>(_internal, "webViewDelegate"));
            if (&webViewDelegate != NULL)
                [webViewDelegate _clearUIWebView];
        }
    }

    [super dealloc];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<%s: %p, %@>", class_getName([self class]), self, [[[self request] URL] absoluteString]];
}

- (id<CyteWebViewDelegate>) delegate {
    return (id<CyteWebViewDelegate>) [super delegate];
}

- (void) setDelegate:(id<CyteWebViewDelegate>)delegate {
    [super setDelegate:delegate];
}

/*- (WebView *) webView:(WebView *)view createWebViewWithRequest:(NSURLRequest *)request {
    id<CyteWebViewDelegate> delegate([self delegate]);
    WebView *created(nil);
    if (created == nil && [delegate respondsToSelector:@selector(webView:createWebViewWithRequest:)])
        created = [delegate webView:view createWebViewWithRequest:request];
    if (created == nil && [UIWebView instancesRespondToSelector:@selector(webView:createWebViewWithRequest:)])
        created = [super webView:view createWebViewWithRequest:request];
    return created;
}*/

// webView:addMessageToConsole: (X.Xx) {{{
static void $UIWebViewWebViewDelegate$webView$addMessageToConsole$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view, NSDictionary *message) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webView:addMessageToConsole:)])
        [uiWebView webView:view addMessageToConsole:message];
}

- (void) webView:(WebView *)view addMessageToConsole:(NSDictionary *)message {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:addMessageToConsole:)])
        [delegate webView:view addMessageToConsole:message];
    if ([UIWebView instancesRespondToSelector:@selector(webView:addMessageToConsole:)])
        [super webView:view addMessageToConsole:message];
}
// }}}
// webView:decidePolicyForNavigationAction:request:frame:decisionListener: (2.0+) {{{
- (void) webView:(WebView *)view decidePolicyForNavigationAction:(NSDictionary *)action request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    id<CyteWebViewDelegate> delegate([self delegate]);
    CYWebPolicyDecisionMediator *mediator([[[CYWebPolicyDecisionMediator alloc] initWithListener:listener] autorelease]);
    if (![mediator decided] && [delegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)])
        [delegate webView:view decidePolicyForNavigationAction:action request:request frame:frame decisionListener:mediator];
    if (![mediator decided] && [UIWebView instancesRespondToSelector:@selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:)])
        [super webView:view decidePolicyForNavigationAction:action request:request frame:frame decisionListener:mediator];
    if ([delegate respondsToSelector:@selector(webView:didDecidePolicy:forNavigationAction:request:frame:)])
        [delegate webView:view didDecidePolicy:[mediator decision] forNavigationAction:action request:request frame:frame];
    [mediator decide];
}
// }}}
// webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener: (3.0+) {{{
static void $UIWebViewWebViewDelegate$webView$decidePolicyForNewWindowAction$request$newFrameName$decisionListener$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view, NSDictionary *action, NSURLRequest *request, NSString *frame, id<WebPolicyDecisionListener> listener) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)])
        [uiWebView webView:view decidePolicyForNewWindowAction:action request:request newFrameName:frame decisionListener:listener];
}

- (void) webView:(WebView *)view decidePolicyForNewWindowAction:(NSDictionary *)action request:(NSURLRequest *)request newFrameName:(NSString *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    id<CyteWebViewDelegate> delegate([self delegate]);
    CYWebPolicyDecisionMediator *mediator([[[CYWebPolicyDecisionMediator alloc] initWithListener:listener] autorelease]);
    if (![mediator decided] && [delegate respondsToSelector:@selector(webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)])
        [delegate webView:view decidePolicyForNewWindowAction:action request:request newFrameName:frame decisionListener:mediator];
    if (![mediator decided] && [UIWebView instancesRespondToSelector:@selector(webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:)])
        [super webView:view decidePolicyForNewWindowAction:action request:request newFrameName:frame decisionListener:mediator];
    [mediator decide];
}
// }}}
// webView:didClearWindowObject:forFrame: (3.2+) {{{
static void $UIWebViewWebViewDelegate$webView$didClearWindowObject$forFrame$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view, WebScriptObject *window, WebFrame *frame) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webView:didClearWindowObject:forFrame:)])
        [uiWebView webView:view didClearWindowObject:window forFrame:frame];
}

- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didClearWindowObject:forFrame:)])
        [delegate webView:view didClearWindowObject:window forFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didClearWindowObject:forFrame:)])
        [super webView:view didClearWindowObject:window forFrame:frame];
}
// }}}
// webView:didCommitLoadForFrame: (3.0+) {{{
static void $UIWebViewWebViewDelegate$webView$didCommitLoadForFrame$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view, WebFrame *frame) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webView:didCommitLoadForFrame:)])
        [uiWebView webView:view didCommitLoadForFrame:frame];
}

- (void) webView:(WebView *)view didCommitLoadForFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didCommitLoadForFrame:)])
        [delegate webView:view didCommitLoadForFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didCommitLoadForFrame:)])
        [super webView:view didCommitLoadForFrame:frame];
}
// }}}
// webView:didFailLoadWithError:forFrame: (2.0+) {{{
- (void) webView:(WebView *)view didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didFailLoadWithError:forFrame:)])
        [delegate webView:view didFailLoadWithError:error forFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didFailLoadWithError:forFrame:)])
        [super webView:view didFailLoadWithError:error forFrame:frame];
}
// }}}
// webView:didFailProvisionalLoadWithError:forFrame: (2.0+) {{{
- (void) webView:(WebView *)view didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didFailProvisionalLoadWithError:forFrame:)])
        [delegate webView:view didFailProvisionalLoadWithError:error forFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didFailProvisionalLoadWithError:forFrame:)])
        [super webView:view didFailProvisionalLoadWithError:error forFrame:frame];
}
// }}}
// webView:didFinishLoadForFrame: (2.0+) {{{
- (void) webView:(WebView *)view didFinishLoadForFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)])
        [delegate webView:view didFinishLoadForFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didFinishLoadForFrame:)])
        [super webView:view didFinishLoadForFrame:frame];
}
// }}}
// webView:didReceiveTitle:forFrame: (3.2+) {{{
static void $UIWebViewWebViewDelegate$webView$didReceiveTitle$forFrame$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view, NSString *title, WebFrame *frame) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webView:didReceiveTitle:forFrame:)])
        [uiWebView webView:view didReceiveTitle:title forFrame:frame];
}

- (void) webView:(WebView *)view didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didReceiveTitle:forFrame:)])
        [delegate webView:view didReceiveTitle:title forFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didReceiveTitle:forFrame:)])
        [super webView:view didReceiveTitle:title forFrame:frame];
}
// }}}
// webView:didStartProvisionalLoadForFrame: (2.0+) {{{
- (void) webView:(WebView *)view didStartProvisionalLoadForFrame:(WebFrame *)frame {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webView:didStartProvisionalLoadForFrame:)])
        [delegate webView:view didStartProvisionalLoadForFrame:frame];
    if ([UIWebView instancesRespondToSelector:@selector(webView:didStartProvisionalLoadForFrame:)])
        [super webView:view didStartProvisionalLoadForFrame:frame];
}
// }}}
// webView:resource:didCancelAuthenticationChallenge:fromDataSource: {{{
- (void) webView:(WebView *)view resource:(id)identifier didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)source {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView respondsToSelector:@selector(webView:resource:didCancelAuthenticationChallenge:fromDataSource:)])
        [super webView:view resource:identifier didCancelAuthenticationChallenge:challenge fromDataSource:source];
    if ([delegate respondsToSelector:@selector(webView:resource:didCancelAuthenticationChallenge:fromDataSource:)])
        [delegate webView:view resource:identifier didCancelAuthenticationChallenge:challenge fromDataSource:source];
}
// }}}
// webView:resource:didReceiveAuthenticationChallenge:fromDataSource: {{{
- (void) webView:(WebView *)view resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)source {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView respondsToSelector:@selector(webView:resource:didReceiveAuthenticationChallenge:fromDataSource:)])
        [super webView:view resource:identifier didReceiveAuthenticationChallenge:challenge fromDataSource:source];
    if ([delegate respondsToSelector:@selector(webView:resource:didReceiveAuthenticationChallenge:fromDataSource:)])
        [delegate webView:view resource:identifier didReceiveAuthenticationChallenge:challenge fromDataSource:source];
}
// }}}
// webView:resource:willSendRequest:redirectResponse:fromDataSource: (3.2+) {{{
static NSURLRequest *$UIWebViewWebViewDelegate$webView$resource$willSendRequest$redirectResponse$fromDataSource$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view, id identifier, NSURLRequest *request, NSURLResponse *response, WebDataSource *source) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)])
        request = [uiWebView webView:view resource:identifier willSendRequest:request redirectResponse:response fromDataSource:source];
    return request;
}

- (NSURLRequest *) webView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView instancesRespondToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)])
        request = [super webView:view resource:identifier willSendRequest:request redirectResponse:response fromDataSource:source];
    if ([delegate respondsToSelector:@selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:)])
        request = [delegate webView:view resource:identifier willSendRequest:request redirectResponse:response fromDataSource:source];
    return request;
}
// }}}
// webThreadWebView:resource:willSendRequest:redirectResponse:fromDataSource: {{{
- (NSURLRequest *) webThreadWebView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView instancesRespondToSelector:@selector(webThreadWebView:resource:willSendRequest:redirectResponse:fromDataSource:)])
        request = [super webThreadWebView:view resource:identifier willSendRequest:request redirectResponse:response fromDataSource:source];
    if ([delegate respondsToSelector:@selector(webThreadWebView:resource:willSendRequest:redirectResponse:fromDataSource:)])
        request = [delegate webThreadWebView:view resource:identifier willSendRequest:request redirectResponse:response fromDataSource:source];
    return request;
}
// }}}
// webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame: (2.1+) {{{
- (void) webView:(WebView *)view runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    [[self retain] autorelease];
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView instancesRespondToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:)])
        if (
            ![delegate respondsToSelector:@selector(webView:shouldRunJavaScriptAlertPanelWithMessage:initiatedByFrame:)] ||
            [delegate webView:view shouldRunJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame]
        )
            [super webView:view runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
}
// }}}
// webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame: (2.1+) {{{
- (BOOL) webView:(WebView *)view runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    [[self retain] autorelease];
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView instancesRespondToSelector:@selector(webView:runJavaScriptConfirmPanelWithMessage:initiatedByFrame:)])
        if (
            ![delegate respondsToSelector:@selector(webView:shouldRunJavaScriptConfirmPanelWithMessage:initiatedByFrame:)] ||
            [delegate webView:view shouldRunJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame]
        )
            return [super webView:view runJavaScriptConfirmPanelWithMessage:message initiatedByFrame:frame];
    return NO;
}
// }}}
// webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame: (2.1+) {{{
- (NSString *) webView:(WebView *)view runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)text initiatedByFrame:(WebFrame *)frame {
    [[self retain] autorelease];
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([UIWebView instancesRespondToSelector:@selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:)])
        if (
            ![delegate respondsToSelector:@selector(webView:shouldRunJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:)] ||
            [delegate webView:view shouldRunJavaScriptTextInputPanelWithPrompt:prompt defaultText:text initiatedByFrame:frame]
        )
            return [super webView:view runJavaScriptTextInputPanelWithPrompt:prompt defaultText:text initiatedByFrame:frame];
    return nil;
}
// }}}
// webViewClose: (3.2+) {{{
static void $UIWebViewWebViewDelegate$webViewClose$(UIWebViewWebViewDelegate *self, SEL sel, WebView *view) {
    UIWebView *uiWebView(MSHookIvar<UIWebView *>(self, "uiWebView"));
    if ([uiWebView respondsToSelector:@selector(webViewClose:)])
        [uiWebView webViewClose:view];
}

- (void) webViewClose:(WebView *)view {
    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webViewClose:)])
        [delegate webViewClose:view];
    if ([UIWebView instancesRespondToSelector:@selector(webViewClose:)])
        [super webViewClose:view];
}
// }}}

- (void) _updateViewSettings {
    [super _updateViewSettings];

    id<CyteWebViewDelegate> delegate([self delegate]);
    if ([delegate respondsToSelector:@selector(webViewUpdateViewSettings:)])
        [delegate webViewUpdateViewSettings:self];
}

- (void) dispatchEvent:(NSString *)event {
    [[self _documentView] dispatchEvent:event];
}

- (void) reloadFromOrigin {
    [[[self _documentView] webView] reloadFromOrigin:nil];
}

- (UIScrollView *) scrollView {
    if ([self respondsToSelector:@selector(_scrollView)])
        return [self _scrollView];
    else if ([self respondsToSelector:@selector(_scroller)])
        return (UIScrollView *) [self _scroller];
    else return nil;
}

- (void) setNeedsLayout {
    [super setNeedsLayout];

    WebFrame *frame([[[self _documentView] webView] mainFrame]);
    if ([frame respondsToSelector:@selector(setNeedsLayout)])
        [frame setNeedsLayout];
}

- (NSURLRequest *) request {
    WebFrame *frame([[[self _documentView] webView] mainFrame]);
    return [([frame provisionalDataSource] ?: [frame dataSource]) request];
}

@end

static void $UIWebViewWebViewDelegate$_clearUIWebView(UIWebViewWebViewDelegate *self, SEL sel) {
    MSHookIvar<UIWebView *>(self, "uiWebView") = nil;
}

__attribute__((__constructor__)) static void $() {
    if (Class $UIWebViewWebViewDelegate = objc_getClass("UIWebViewWebViewDelegate")) {
        class_addMethod($UIWebViewWebViewDelegate, @selector(webView:addMessageToConsole:), (IMP) &$UIWebViewWebViewDelegate$webView$addMessageToConsole$, "v16@0:4@8@12");
        class_addMethod($UIWebViewWebViewDelegate, @selector(webView:decidePolicyForNewWindowAction:request:newFrameName:decisionListener:), (IMP) &$UIWebViewWebViewDelegate$webView$decidePolicyForNewWindowAction$request$newFrameName$decisionListener$, "v28@0:4@8@12@16@20@24");
        class_addMethod($UIWebViewWebViewDelegate, @selector(webView:didClearWindowObject:forFrame:), (IMP) &$UIWebViewWebViewDelegate$webView$didClearWindowObject$forFrame$, "v20@0:4@8@12@16");
        class_addMethod($UIWebViewWebViewDelegate, @selector(webView:didCommitLoadForFrame:), (IMP) &$UIWebViewWebViewDelegate$webView$didCommitLoadForFrame$, "v16@0:4@8@12");
        class_addMethod($UIWebViewWebViewDelegate, @selector(webView:didReceiveTitle:forFrame:), (IMP) &$UIWebViewWebViewDelegate$webView$didReceiveTitle$forFrame$, "v20@0:4@8@12@16");
        class_addMethod($UIWebViewWebViewDelegate, @selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:), (IMP) &$UIWebViewWebViewDelegate$webView$resource$willSendRequest$redirectResponse$fromDataSource$, "@28@0:4@8@12@16@20@24");
        class_addMethod($UIWebViewWebViewDelegate, @selector(webViewClose:), (IMP) &$UIWebViewWebViewDelegate$webViewClose$, "v12@0:4@8");
        class_addMethod($UIWebViewWebViewDelegate, @selector(_clearUIWebView), (IMP) &$UIWebViewWebViewDelegate$_clearUIWebView, "v8@0:4");
    }
}

@implementation UIWebDocumentView (Cydia)

- (void) _setScrollerOffset:(CGPoint)offset {
    UIScroller *scroller([self _scroller]);

    CGSize size([scroller contentSize]);
    CGSize bounds([scroller bounds].size);

    CGPoint max;
    max.x = size.width - bounds.width;
    max.y = size.height - bounds.height;

    // wtf Apple?!
    if (max.x < 0)
        max.x = 0;
    if (max.y < 0)
        max.y = 0;

    offset.x = offset.x < 0 ? 0 : offset.x > max.x ? max.x : offset.x;
    offset.y = offset.y < 0 ? 0 : offset.y > max.y ? max.y : offset.y;

    [scroller setOffset:offset];
}

@end
