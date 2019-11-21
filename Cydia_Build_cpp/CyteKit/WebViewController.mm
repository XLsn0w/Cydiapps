#include "CyteKit/UCPlatform.h"

#include "CyteKit/IndirectDelegate.h"
#include "CyteKit/Localize.h"
#include "CyteKit/MFMailComposeViewController-MailToURL.h"
#include "CyteKit/RegEx.hpp"
#include "CyteKit/WebThreadLocked.hpp"
#include "CyteKit/WebViewController.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

//#include <QuartzCore/CALayer.h>
// XXX: fix the minimum requirement
extern NSString * const kCAFilterNearest;

#include <WebCore/WebCoreThread.h>

#include <dlfcn.h>
#include <objc/runtime.h>

#include "Substrate.hpp"

#define ForSaurik 0
#define DefaultTimeout_ 120.0

#define ShowInternals 0
#define LogBrowser 0
#define LogMessages 0

#define lprintf(args...) fprintf(stderr, args)

JSValueRef (*$JSObjectCallAsFunction)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[], JSValueRef *);

// XXX: centralize these special class things to some file or mechanism?
static Class $MFMailComposeViewController;

float CYScrollViewDecelerationRateNormal;

@interface WebFrame (Cydia)
- (void) cydia$updateHeight;
@end

@implementation WebFrame (Cydia)

- (NSString *) description {
    return [NSString stringWithFormat:@"<%s: %p, %@>", class_getName([self class]), self, [[[([self provisionalDataSource] ?: [self dataSource]) request] URL] absoluteString]];
}

- (void) cydia$updateHeight {
    [[[self frameElement] style]
        setProperty:@"height"
        value:[NSString stringWithFormat:@"%dpx",
            [[[self DOMDocument] body] scrollHeight]]
        priority:nil];
}

@end

// Diversion {{{
static _H<NSMutableSet> Diversions_;

@implementation Diversion {
    RegEx pattern_;
    _H<NSString> key_;
    _H<NSString> format_;
}

- (id) initWithFrom:(NSString *)from to:(NSString *)to {
    if ((self = [super init]) != nil) {
        pattern_ = [from UTF8String];
        key_ = from;
        format_ = to;
    } return self;
}

- (NSString *) divert:(NSString *)url {
    return !pattern_(url) ? nil : pattern_->*format_;
}

+ (NSURL *) divertURL:(NSURL *)url {
  divert:
    NSString *href([url absoluteString]);

    for (Diversion *diversion in (id) Diversions_)
        if (NSString *diverted = [diversion divert:href]) {
#if !ForRelease
            NSLog(@"div: %@", diverted);
#endif
            url = [NSURL URLWithString:diverted];
            goto divert;
        }

    return url;
}

- (NSString *) key {
    return key_;
}

- (NSUInteger) hash {
    return [key_ hash];
}

- (BOOL) isEqual:(Diversion *)object {
    return self == object || [self class] == [object class] && [key_ isEqual:[object key]];
}

@end
// }}}
/* Indirect Delegate {{{ */
@implementation IndirectDelegate

- (id) delegate {
    return delegate_;
}

- (void) setDelegate:(id)delegate {
    delegate_ = delegate;
}

- (id) initWithDelegate:(id)delegate {
    delegate_ = delegate;
    return self;
}

- (IMP) methodForSelector:(SEL)sel {
    if (IMP method = [super methodForSelector:sel])
        return method;
    fprintf(stderr, "methodForSelector:[%s] == NULL\n", sel_getName(sel));
    return NULL;
}

- (BOOL) respondsToSelector:(SEL)sel {
    if ([super respondsToSelector:sel])
        return YES;

    // XXX: WebThreadCreateNSInvocation returns nil

#if ShowInternals
    fprintf(stderr, "[%s]R?%s\n", class_getName(object_getClass(self)), sel_getName(sel));
#endif

    return delegate_ == nil ? NO : [delegate_ respondsToSelector:sel];
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel {
    if (NSMethodSignature *method = [super methodSignatureForSelector:sel])
        return method;

#if ShowInternals
    fprintf(stderr, "[%s]S?%s\n", class_getName(object_getClass(self)), sel_getName(sel));
#endif

    if (delegate_ != nil)
        if (NSMethodSignature *sig = [delegate_ methodSignatureForSelector:sel])
            return sig;

    // XXX: I fucking hate Apple so very very bad
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void) forwardInvocation:(NSInvocation *)inv {
    SEL sel = [inv selector];
    if (delegate_ != nil && [delegate_ respondsToSelector:sel])
        [inv invokeWithTarget:delegate_];
}

@end
/* }}} */

@implementation CyteWebViewController {
    _H<CyteWebView, 1> webview_;
    _transient UIScrollView *scroller_;

    _H<UIActivityIndicatorView> indicator_;
    _H<IndirectDelegate, 1> indirect_;
    _H<NSURLAuthenticationChallenge> challenge_;

    bool error_;
    _H<NSURLRequest> request_;
    bool ready_;

    _transient NSNumber *sensitive_;
    _H<NSURL> appstore_;

    _H<NSString> title_;
    _H<NSMutableSet> loading_;

    _H<NSMutableSet> registered_;
    _H<NSTimer> timer_;

    // XXX: NSString * or UIImage *
    _H<NSObject> custom_;
    _H<NSString> style_;

    _H<WebScriptObject> function_;

    float width_;
    Class class_;

    _H<UIBarButtonItem> reloaditem_;
    _H<UIBarButtonItem> loadingitem_;

    bool visible_;
    bool hidesNavigationBar_;
    bool allowsNavigationAction_;
}

#if ShowInternals
#include "CyteKit/UCInternal.h"
#endif

+ (void) _initialize {
    [WebPreferences _setInitialDefaultTextEncodingToSystemEncoding];

    void *js(NULL);
    if (js == NULL)
        js = dlopen("/System/Library/Frameworks/JavaScriptCore.framework/JavaScriptCore", RTLD_GLOBAL | RTLD_LAZY);
    if (js == NULL)
        js = dlopen("/System/Library/PrivateFrameworks/JavaScriptCore.framework/JavaScriptCore", RTLD_GLOBAL | RTLD_LAZY);
    if (js != NULL)
        $JSObjectCallAsFunction = reinterpret_cast<JSValueRef (*)(JSContextRef, JSObjectRef, JSObjectRef, size_t, const JSValueRef[], JSValueRef *)>(dlsym(js, "JSObjectCallAsFunction"));

    dlopen("/System/Library/Frameworks/MessageUI.framework/MessageUI", RTLD_GLOBAL | RTLD_LAZY);
    $MFMailComposeViewController = objc_getClass("MFMailComposeViewController");

    if (CGFloat *_UIScrollViewDecelerationRateNormal = reinterpret_cast<CGFloat *>(dlsym(RTLD_DEFAULT, "UIScrollViewDecelerationRateNormal")))
        CYScrollViewDecelerationRateNormal = *_UIScrollViewDecelerationRateNormal;
    else // XXX: this actually might be fast on some older systems: we should look into this
        CYScrollViewDecelerationRateNormal = 0.998;

    Diversions_ = [NSMutableSet setWithCapacity:0];
}

- (bool) retainsNetworkActivityIndicator {
    return true;
}

- (void) releaseNetworkActivityIndicator {
    if ([loading_ count] != 0) {
        [loading_ removeAllObjects];

        if ([self retainsNetworkActivityIndicator])
            [self.delegate releaseNetworkActivityIndicator];
    }
}

- (void) dealloc {
#if LogBrowser
    NSLog(@"[CyteWebViewController dealloc]");
#endif

    [self releaseNetworkActivityIndicator];

    [super dealloc];
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<%s: %p, %@>", class_getName([self class]), self, [[request_ URL] absoluteString]];
}

- (CyteWebView *) webView {
    return (CyteWebView *) [self view];
}

- (CyteWebViewController *) indirect {
    return (CyteWebViewController *) (IndirectDelegate *) indirect_;
}

+ (void) addDiversion:(Diversion *)diversion {
    [Diversions_ addObject:diversion];
}

- (NSURL *) URLWithURL:(NSURL *)url {
    return [Diversion divertURL:url];
}

- (NSURLRequest *) requestWithURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)policy referrer:(NSString *)referrer {
    NSMutableURLRequest *request([NSMutableURLRequest
        requestWithURL:[self URLWithURL:url]
        cachePolicy:policy
        timeoutInterval:DefaultTimeout_
    ]);

    [request setValue:referrer forHTTPHeaderField:@"Referer"];

    return request;
}

- (void) setRequest:(NSURLRequest *)request {
    _assert(request_ == nil);
    request_ = request;
}

- (NSURLRequest *) request {
    return request_;
}

- (void) setURL:(NSURL *)url {
    [self setURL:url withReferrer:nil];
}

- (void) setURL:(NSURL *)url withReferrer:(NSString *)referrer {
    [self setRequest:[self requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy referrer:referrer]];
}

- (void) loadURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)policy {
    [self loadRequest:[self requestWithURL:url cachePolicy:policy referrer:nil]];
}

- (void) loadURL:(NSURL *)url {
    [self loadURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy];
}

- (void) loadRequest:(NSURLRequest *)request {
#if LogBrowser
    NSLog(@"loadRequest:%@", request);
#endif

    error_ = false;
    ready_ = true;

    WebThreadLocked lock;
    [[self webView] loadRequest:request];
}

- (void) reloadURLWithCache:(BOOL)cache {
    if (request_ == nil)
        return;

    NSMutableURLRequest *request([request_ mutableCopy]);
    [request setCachePolicy:(cache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData)];

    request_ = request;

    if (cache || [request_ HTTPBody] == nil && [request_ HTTPBodyStream] == nil)
        [self loadRequest:request_];
    else {
        UIAlertView *alert = [[[UIAlertView alloc]
            initWithTitle:UCLocalize("RESUBMIT_FORM")
            message:nil
            delegate:self
            cancelButtonTitle:UCLocalize("CANCEL")
            otherButtonTitles:
                UCLocalize("SUBMIT"),
            nil
        ] autorelease];

        [alert setContext:@"submit"];
        [alert show];
    }
}

- (void) reloadData {
    [super reloadData];

    if (ready_)
        [self dispatchEvent:@"CydiaReloadData"];
    else
        [self reloadURLWithCache:YES];
}

- (void) setButtonImage:(NSString *)button withStyle:(NSString *)style toFunction:(id)function {
    custom_ = button;
    style_ = style;
    function_ = function;

    [self performSelectorOnMainThread:@selector(applyRightButton) withObject:nil waitUntilDone:NO];
}

- (void) setButtonTitle:(NSString *)button withStyle:(NSString *)style toFunction:(id)function {
    custom_ = button;
    style_ = style;
    function_ = function;

    [self performSelectorOnMainThread:@selector(applyRightButton) withObject:nil waitUntilDone:NO];
}

- (void) removeButton {
    custom_ = [NSNull null];
    [self performSelectorOnMainThread:@selector(applyRightButton) withObject:nil waitUntilDone:NO];
}

- (void) scrollToBottomAnimated:(NSNumber *)animated {
    CGSize size([scroller_ contentSize]);
    CGPoint offset([scroller_ contentOffset]);
    CGRect frame([scroller_ frame]);

    if (size.height - offset.y < frame.size.height + 20.f) {
        CGRect rect = {{0, size.height-1}, {size.width, 1}};
        [scroller_ scrollRectToVisible:rect animated:[animated boolValue]];
    }
}

- (void) _setViewportWidth {
    [[[self webView] _documentView] setViewportSize:CGSizeMake(width_, UIWebViewGrowsAndShrinksToFitHeight) forDocumentTypes:0x10];
}

- (void) setViewportWidth:(float)width {
    width_ = width != 0 ? width : [[self class] defaultWidth];
    [self _setViewportWidth];
}

- (void) _setViewportWidthOnMainThread:(NSNumber *)width {
    [self setViewportWidth:[width floatValue]];
}

- (void) setViewportWidthOnMainThread:(float)width {
    [self performSelectorOnMainThread:@selector(_setViewportWidthOnMainThread:) withObject:[NSNumber numberWithFloat:width] waitUntilDone:NO];
}

- (void) webViewUpdateViewSettings:(UIWebView *)view {
    [self _setViewportWidth];
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) _setupMail:(MFMailComposeViewController *)controller {
}

- (void) _openMailToURL:(NSURL *)url {
    if ($MFMailComposeViewController != nil && [$MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller([[[$MFMailComposeViewController alloc] init] autorelease]);
        [controller setMailComposeDelegate:self];

        [controller setMailToURL:url];

        [self _setupMail:controller];

        [self presentModalViewController:controller animated:YES];
        return;
    }

    UIApplication *app([UIApplication sharedApplication]);
    if ([app respondsToSelector:@selector(openURL:asPanel:)])
        [app openURL:url asPanel:YES];
    else
        [app openURL:url];
}

- (bool) _allowJavaScriptPanel {
    return true;
}

- (bool) allowsNavigationAction {
    return allowsNavigationAction_;
}

- (void) setAllowsNavigationAction:(bool)value {
    allowsNavigationAction_ = value;
}

- (void) setAllowsNavigationActionByNumber:(NSNumber *)value {
    [self setAllowsNavigationAction:[value boolValue]];
}

- (void) popViewControllerWithNumber:(NSNumber *)value {
    UINavigationController *navigation([self navigationController]);
    if ([navigation topViewController] == self)
        [navigation popViewControllerAnimated:[value boolValue]];
}

- (void) _didFailWithError:(NSError *)error forFrame:(WebFrame *)frame {
    NSValue *object([NSValue valueWithNonretainedObject:frame]);
    if (![loading_ containsObject:object])
        return;
    [loading_ removeObject:object];

    [self _didFinishLoading];

    if ([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorCancelled)
        return;

    if ([[error domain] isEqualToString:WebKitErrorDomain] && [error code] == WebKitErrorFrameLoadInterruptedByPolicyChange) {
        request_ = nil;
        return;
    }

    if ([frame parentFrame] == nil) {
        [self loadURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",
            [[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"]] absoluteString],
            [[error localizedDescription] stringByAddingPercentEscapes]
        ]]];

        error_ = true;
    }
}

- (void) pushRequest:(NSURLRequest *)request forAction:(NSDictionary *)action asPop:(bool)pop {
    WebFrame *frame(nil);
    if (NSDictionary *WebActionElement = [action objectForKey:@"WebActionElementKey"])
        frame = [WebActionElement objectForKey:@"WebElementFrame"];
    if (frame == nil)
        frame = [[[[self webView] _documentView] webView] mainFrame];

    WebDataSource *source([frame provisionalDataSource] ?: [frame dataSource]);
    NSString *referrer([request valueForHTTPHeaderField:@"Referer"] ?: [[[source request] URL] absoluteString]);

    NSURL *url([request URL]);

    // XXX: filter to internal usage?
    CyteViewController *page([self.delegate pageForURL:url forExternal:NO withReferrer:referrer]);

    if (page == nil) {
        CyteWebViewController *browser([[[class_ alloc] init] autorelease]);
        [browser setRequest:request];
        page = browser;
    }

    [page setDelegate:self.delegate];
    [page setPageColor:self.pageColor];

    if (!pop) {
        [[self navigationItem] setTitle:title_];

        [[self navigationController] pushViewController:page animated:YES];
    } else {
        UINavigationController *navigation([[[UINavigationController alloc] initWithRootViewController:page] autorelease]);

        [navigation setDelegate:self.delegate];

        [[page navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("CLOSE")
            style:UIBarButtonItemStylePlain
            target:page
            action:@selector(close)
        ] autorelease]];

        [[self navigationController] presentModalViewController:navigation animated:YES];
    }
}

// CyteWebViewDelegate {{{
- (void) webView:(WebView *)view addMessageToConsole:(NSDictionary *)message {
#if LogMessages
    static RegEx irritating("(?"
        ":" "The page at .* displayed insecure content from .*\\."
        "|" "Unsafe JavaScript attempt to access frame with URL .* from frame with URL .*\\. Domains, protocols and ports must match\\."
    ")\\n");

    if (NSString *data = [message objectForKey:@"message"])
        if (irritating(data))
            return;

    NSLog(@"addMessageToConsole:%@", message);
#endif
}

- (void) webView:(WebView *)view decidePolicyForNavigationAction:(NSDictionary *)action request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
#if LogBrowser
    NSLog(@"decidePolicyForNavigationAction:%@ request:%@ %@ frame:%@", action, request, [request allHTTPHeaderFields], frame);
#endif

    NSURL *url(request == nil ? nil : [request URL]);
    NSString *scheme([[url scheme] lowercaseString]);
    NSString *absolute([[url absoluteString] lowercaseString]);

    if (
        [scheme isEqualToString:@"itms"] ||
        [scheme isEqualToString:@"itmss"] ||
        [scheme isEqualToString:@"itms-apps"] ||
        [scheme isEqualToString:@"itms-appss"] ||
        [absolute hasPrefix:@"http://itunes.apple.com/"] ||
        [absolute hasPrefix:@"https://itunes.apple.com/"] ||
    false) {
        appstore_ = url;

        UIAlertView *alert = [[[UIAlertView alloc]
            initWithTitle:UCLocalize("APP_STORE_REDIRECT")
            message:nil
            delegate:self
            cancelButtonTitle:UCLocalize("CANCEL")
            otherButtonTitles:
                UCLocalize("ALLOW"),
            nil
        ] autorelease];

        [alert setContext:@"itmsappss"];
        [alert show];

        [listener ignore];
        return;
    }

    if ([frame parentFrame] == nil) {
        if (!error_) {
            if (request_ != nil && ![[request_ URL] isEqual:url] && ![self allowsNavigationAction]) {
                if (url != nil)
                    [self pushRequest:request forAction:action asPop:NO];
                [listener ignore];
            }
        }
    }
}

- (void) webView:(WebView *)view didDecidePolicy:(CYWebPolicyDecision)decision forNavigationAction:(NSDictionary *)action request:(NSURLRequest *)request frame:(WebFrame *)frame {
#if LogBrowser
    NSLog(@"didDecidePolicy:%u forNavigationAction:%@ request:%@ %@ frame:%@", decision, action, request, [request allHTTPHeaderFields], frame);
#endif

    if ([frame parentFrame] == nil) {
        switch (decision) {
            case CYWebPolicyDecisionIgnore:
                if ([[request_ URL] isEqual:[request URL]])
                    request_ = nil;
            break;

            case CYWebPolicyDecisionUse:
                if (!error_)
                    request_ = request;
            break;

            default:
            break;
        }
    }
}

- (void) webView:(WebView *)view decidePolicyForNewWindowAction:(NSDictionary *)action request:(NSURLRequest *)request newFrameName:(NSString *)name decisionListener:(id<WebPolicyDecisionListener>)listener {
#if LogBrowser
    NSLog(@"decidePolicyForNewWindowAction:%@ request:%@ %@ newFrameName:%@", action, request, [request allHTTPHeaderFields], name);
#endif

    NSURL *url([request URL]);
    if (url == nil)
        return;

    if ([name isEqualToString:@"_open"])
        [self.delegate openURL:url];
    else {
        NSString *scheme([[url scheme] lowercaseString]);
        if ([scheme isEqualToString:@"mailto"])
            [self _openMailToURL:url];
        else
            [self pushRequest:request forAction:action asPop:[name isEqualToString:@"_popup"]];
    }

    [listener ignore];
}

- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
#if LogBrowser
    NSLog(@"didClearWindowObject:%@ forFrame:%@", window, frame);
#endif
}

- (void) webView:(WebView *)view didCommitLoadForFrame:(WebFrame *)frame {
#if LogBrowser
    NSLog(@"didCommitLoadForFrame:%@", frame);
#endif

    if ([frame parentFrame] == nil) {
    }
}

- (void) webView:(WebView *)view didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
#if LogBrowser
    NSLog(@"didFailLoadWithError:%@ forFrame:%@", error, frame);
#endif

    [self _didFailWithError:error forFrame:frame];
}

- (void) webView:(WebView *)view didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
#if LogBrowser
    NSLog(@"didFailProvisionalLoadWithError:%@ forFrame:%@", error, frame);
#endif

    [self _didFailWithError:error forFrame:frame];
}

- (void) webView:(WebView *)view didFinishLoadForFrame:(WebFrame *)frame {
    NSValue *object([NSValue valueWithNonretainedObject:frame]);
    if (![loading_ containsObject:object])
        return;
    [loading_ removeObject:object];

    if ([frame parentFrame] == nil) {
        if (DOMDocument *document = [frame DOMDocument])
            if (DOMNodeList *bodies = [document getElementsByTagName:@"body"])
                for (DOMHTMLBodyElement *body in (id) bodies) {
                    DOMCSSStyleDeclaration *style([document getComputedStyle:body pseudoElement:nil]);

                    UIColor *uic(nil);

                    if (DOMCSSPrimitiveValue *color = static_cast<DOMCSSPrimitiveValue *>([style getPropertyCSSValue:@"background-color"])) {
                        if ([color primitiveType] == DOM_CSS_RGBCOLOR) {
                            DOMRGBColor *rgb([color getRGBColorValue]);

                            float red([[rgb red] getFloatValue:DOM_CSS_NUMBER]);
                            float green([[rgb green] getFloatValue:DOM_CSS_NUMBER]);
                            float blue([[rgb blue] getFloatValue:DOM_CSS_NUMBER]);
                            float alpha([[rgb alpha] getFloatValue:DOM_CSS_NUMBER]);

                            if (alpha == 1)
                                uic = [UIColor
                                    colorWithRed:(red / 255)
                                    green:(green / 255)
                                    blue:(blue / 255)
                                    alpha:alpha
                                ];
                        }
                    }

                    [super setPageColor:uic];
                    [scroller_ setBackgroundColor:self.pageColor];
                    break;
                }
    }

    [self _didFinishLoading];
}

- (void) webView:(WebView *)view didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    if ([frame parentFrame] != nil)
        return;

    title_ = title;

    [[self navigationItem] setTitle:title_];
}

- (void) webView:(WebView *)view didStartProvisionalLoadForFrame:(WebFrame *)frame {
#if LogBrowser
    NSLog(@"didStartProvisionalLoadForFrame:%@", frame);
#endif

    [loading_ addObject:[NSValue valueWithNonretainedObject:frame]];

    if ([frame parentFrame] == nil) {
        title_ = nil;
        custom_ = nil;
        style_ = nil;
        function_ = nil;

        [registered_ removeAllObjects];
        timer_ = nil;

        allowsNavigationAction_ = true;

        [self setHidesNavigationBar:NO];
        [self setScrollAlwaysBounceVertical:true];
        [self setScrollIndicatorStyle:UIScrollViewIndicatorStyleDefault];

        // XXX: do we still need to do this?
        [[self navigationItem] setTitle:nil];
    }

    [self _didStartLoading];
}

- (void) webView:(WebView *)view resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)source {
    challenge_ = [challenge retain];

    NSURLProtectionSpace *space([challenge protectionSpace]);
    NSString *realm([space realm]);
    if (realm == nil)
        realm = @"";

    UIAlertView *alert = [[[UIAlertView alloc]
        initWithTitle:realm
        message:nil
        delegate:self
        cancelButtonTitle:UCLocalize("CANCEL")
        otherButtonTitles:UCLocalize("LOGIN"), nil
    ] autorelease];

    [alert setContext:@"challenge"];
    [alert setNumberOfRows:1];

    [alert addTextFieldWithValue:@"" label:UCLocalize("USERNAME")];
    [alert addTextFieldWithValue:@"" label:UCLocalize("PASSWORD")];

    UITextField *username([alert textFieldAtIndex:0]); {
        NSObject<UITextInputTraits> *traits([username textInputTraits]);
        [traits setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [traits setAutocorrectionType:UITextAutocorrectionTypeNo];
        [traits setKeyboardType:UIKeyboardTypeASCIICapable];
        [traits setReturnKeyType:UIReturnKeyNext];
    }

    UITextField *password([alert textFieldAtIndex:1]); {
        NSObject<UITextInputTraits> *traits([password textInputTraits]);
        [traits setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [traits setAutocorrectionType:UITextAutocorrectionTypeNo];
        [traits setKeyboardType:UIKeyboardTypeASCIICapable];
        // XXX: UIReturnKeyDone
        [traits setReturnKeyType:UIReturnKeyNext];
        [traits setSecureTextEntry:YES];
    }

    [alert show];
}

- (NSURLRequest *) webView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source {
#if LogBrowser
    NSLog(@"resource:%@ willSendRequest:%@ redirectResponse:%@ fromDataSource:%@", identifier, request, response, source);
#endif

    return request;
}

- (NSURLRequest *) webThreadWebView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source {
#if LogBrowser
    NSLog(@"resource:%@ willSendRequest:%@ redirectResponse:%@ fromDataSource:%@", identifier, request, response, source);
#endif

    return request;
}

- (bool) webView:(WebView *)view shouldRunJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    return [self _allowJavaScriptPanel];
}

- (bool) webView:(WebView *)view shouldRunJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    return [self _allowJavaScriptPanel];
}

- (bool) webView:(WebView *)view shouldRunJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)text initiatedByFrame:(WebFrame *)frame {
    return [self _allowJavaScriptPanel];
}

- (void) webViewClose:(WebView *)view {
    [self close];
}
// }}}

- (void) close {
    [[[self navigationController] parentOrPresentingViewController] dismissModalViewControllerAnimated:YES];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button {
    NSString *context([alert context]);

    if ([context isEqualToString:@"sensitive"]) {
        switch (button) {
            case 1:
                sensitive_ = [NSNumber numberWithBool:YES];
            break;

            case 2:
                sensitive_ = [NSNumber numberWithBool:NO];
            break;
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"challenge"]) {
        id<NSURLAuthenticationChallengeSender> sender([challenge_ sender]);

        if (button == [alert cancelButtonIndex])
            [sender cancelAuthenticationChallenge:challenge_];
        else if (button == [alert firstOtherButtonIndex]) {
            NSString *username([[alert textFieldAtIndex:0] text]);
            NSString *password([[alert textFieldAtIndex:1] text]);

            NSURLCredential *credential([NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession]);

            [sender useCredential:credential forAuthenticationChallenge:challenge_];
        }

        challenge_ = nil;

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"itmsappss"]) {
        if (button == [alert cancelButtonIndex]) {
        } else if (button == [alert firstOtherButtonIndex]) {
            [self.delegate openURL:appstore_];
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"submit"]) {
        if (button == [alert cancelButtonIndex]) {
        } else if (button == [alert firstOtherButtonIndex]) {
            if (request_ != nil) {
                WebThreadLocked lock;
                [[self webView] loadRequest:request_];
            }
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (UIBarButtonItemStyle) rightButtonStyle {
    if (style_ == nil) normal:
        return UIBarButtonItemStylePlain;
    else if ([style_ isEqualToString:@"Normal"])
        return UIBarButtonItemStylePlain;
    else if ([style_ isEqualToString:@"Highlighted"])
        return UIBarButtonItemStyleDone;
    else goto normal;
}

- (UIBarButtonItem *) customButton {
    if (custom_ == nil)
        return [self rightButton];
    else if ((/*clang:*/id) custom_ == [NSNull null])
        return nil;

    return [[[UIBarButtonItem alloc]
        initWithTitle:static_cast<NSString *>(custom_.operator NSObject *())
        style:[self rightButtonStyle]
        target:self
        action:@selector(customButtonClicked)
    ] autorelease];
}

- (UIBarButtonItem *) leftButton {
    UINavigationItem *item([self navigationItem]);
    if ([item backBarButtonItem] != nil && ![item hidesBackButton])
        return nil;

    if (UINavigationController *navigation = [self navigationController])
        if ([[navigation parentOrPresentingViewController] modalViewController] == navigation)
            return [[[UIBarButtonItem alloc]
                initWithTitle:UCLocalize("CLOSE")
                style:UIBarButtonItemStylePlain
                target:self
                action:@selector(close)
            ] autorelease];

    return nil;
}

- (void) applyLeftButton {
    [[self navigationItem] setLeftBarButtonItem:[self leftButton]];
}

- (UIBarButtonItem *) rightButton {
    return reloaditem_;
}

- (void) applyLoadingTitle {
    [[self navigationItem] setTitle:UCLocalize("LOADING")];
}

- (void) layoutRightButton {
    [[loadingitem_ view] addSubview:indicator_];
    [[loadingitem_ view] bringSubviewToFront:indicator_];
}

- (void) applyRightButton {
    if ([self isLoading]) {
        [[self navigationItem] setRightBarButtonItem:loadingitem_ animated:YES];
        [self performSelector:@selector(layoutRightButton) withObject:nil afterDelay:0];

        [indicator_ startAnimating];
        [self applyLoadingTitle];
    } else {
        [indicator_ stopAnimating];
        [[self navigationItem] setRightBarButtonItem:[self customButton] animated:YES];
    }
}

- (void) didStartLoading {
    // Overridden in subclasses.
}

- (void) _didStartLoading {
    [self applyRightButton];

    if ([loading_ count] != 1)
        return;

    if ([self retainsNetworkActivityIndicator])
        [self.delegate retainNetworkActivityIndicator];

    [self didStartLoading];
}

- (void) didFinishLoading {
    // Overridden in subclasses.
}

- (void) _didFinishLoading {
    if ([loading_ count] != 0)
        return;

    [self applyRightButton];
    [[self navigationItem] setTitle:title_];

    if ([self retainsNetworkActivityIndicator])
        [self.delegate releaseNetworkActivityIndicator];

    [self didFinishLoading];
}

- (bool) isLoading {
    return [loading_ count] != 0;
}

- (id) initWithWidth:(float)width ofClass:(Class)_class {
    if ((self = [super init]) != nil) {
        width_ = width;
        class_ = _class;

        [super setPageColor:nil];

        allowsNavigationAction_ = true;

        loading_ = [NSMutableSet setWithCapacity:5];
        registered_ = [NSMutableSet setWithCapacity:5];
        indirect_ = [[[IndirectDelegate alloc] initWithDelegate:self] autorelease];

        reloaditem_ = [[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("RELOAD")
            style:[self rightButtonStyle]
            target:self
            action:@selector(reloadButtonClicked)
        ] autorelease];

        loadingitem_ = [[[UIBarButtonItem alloc]
            initWithTitle:(kCFCoreFoundationVersionNumber >= 800 ? @"       " : @" ")
            style:UIBarButtonItemStylePlain
            target:self
            action:@selector(customButtonClicked)
        ] autorelease];

        UIActivityIndicatorViewStyle style;
        float left;
        if (kCFCoreFoundationVersionNumber >= 800) {
            style = UIActivityIndicatorViewStyleGray;
            left = 7;
        } else {
            style = UIActivityIndicatorViewStyleWhite;
            left = 15;
        }

        indicator_ = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style] autorelease];
        [indicator_ setFrame:CGRectMake(left, 5, [indicator_ frame].size.width, [indicator_ frame].size.height)];
        [indicator_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];

        [self applyLeftButton];
        [self applyRightButton];
    } return self;
}

static _H<NSString> UserAgent_;
+ (void) setApplicationNameForUserAgent:(NSString *)userAgent {
    UserAgent_ = userAgent;
}

- (NSString *) applicationNameForUserAgent {
    return UserAgent_;
}

- (void) loadView {
    CGRect bounds([[UIScreen mainScreen] applicationFrame]);

    webview_ = [[[CyteWebView alloc] initWithFrame:bounds] autorelease];
    [webview_ setDelegate:self];
    [self setView:webview_];

    if ([webview_ respondsToSelector:@selector(setDataDetectorTypes:)])
        [webview_ setDataDetectorTypes:UIDataDetectorTypeAutomatic];
    else
        [webview_ setDetectsPhoneNumbers:NO];

    [webview_ setScalesPageToFit:YES];

    UIWebDocumentView *document([webview_ _documentView]);

    // XXX: I think this improves scrolling; the hardcoded-ness sucks
    [document setTileSize:CGSizeMake(320, 500)];

    WebView *webview([document webView]);
    WebPreferences *preferences([webview preferences]);

    // XXX: I have no clue if I actually /want/ this modification
    if ([webview respondsToSelector:@selector(_setLayoutInterval:)])
        [webview _setLayoutInterval:0];
    else if ([preferences respondsToSelector:@selector(_setLayoutInterval:)])
        [preferences _setLayoutInterval:0];

    [preferences setCacheModel:WebCacheModelDocumentBrowser];
    [preferences setJavaScriptCanOpenWindowsAutomatically:NO];

    if ([preferences respondsToSelector:@selector(setOfflineWebApplicationCacheEnabled:)])
        [preferences setOfflineWebApplicationCacheEnabled:YES];

    if (NSString *agent = [self applicationNameForUserAgent])
        [webview setApplicationNameForUserAgent:agent];

    if ([webview respondsToSelector:@selector(setShouldUpdateWhileOffscreen:)])
        [webview setShouldUpdateWhileOffscreen:NO];

#if LogMessages
    if ([document respondsToSelector:@selector(setAllowsMessaging:)])
        [document setAllowsMessaging:YES];
    if ([webview respondsToSelector:@selector(_setAllowsMessaging:)])
        [webview _setAllowsMessaging:YES];
#endif

    if ([webview_ respondsToSelector:@selector(_scrollView)]) {
        scroller_ = [webview_ _scrollView];

        [scroller_ setDirectionalLockEnabled:YES];
        [scroller_ setDecelerationRate:CYScrollViewDecelerationRateNormal];
        [scroller_ setDelaysContentTouches:NO];

        [scroller_ setCanCancelContentTouches:YES];
    } else if ([webview_ respondsToSelector:@selector(_scroller)]) {
        UIScroller *scroller([webview_ _scroller]);
        scroller_ = (UIScrollView *) scroller;

        [scroller setDirectionalScrolling:YES];
        // XXX: we might be better off /not/ setting this on older systems
        [scroller setScrollDecelerationFactor:CYScrollViewDecelerationRateNormal]; /* 0.989324 */
        [scroller setScrollHysteresis:0]; /* 8 */

        [scroller setThumbDetectionEnabled:NO];

        // use NO with UIApplicationUseLegacyEvents(YES)
        [scroller setEventMode:YES];

        // XXX: this is handled by setBounces, right?
        //[scroller setAllowsRubberBanding:YES];
    }

    [webview_ setOpaque:NO];
    [webview_ setBackgroundColor:nil];

    [scroller_ setFixedBackgroundPattern:YES];
    [scroller_ setBackgroundColor:self.pageColor];
    [scroller_ setClipsSubviews:YES];

    [scroller_ setBounces:YES];
    [scroller_ setScrollingEnabled:YES];
    [scroller_ setShowBackgroundShadow:NO];

    [self setViewportWidth:width_];

    if ([[UIColor groupTableViewBackgroundColor] isEqual:[UIColor clearColor]]) {
        UITableView *table([[[UITableView alloc] initWithFrame:[webview_ bounds] style:UITableViewStyleGrouped] autorelease]);
        [table setScrollsToTop:NO];
        [webview_ insertSubview:table atIndex:0];
        [table setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    }

    [webview_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];

    ready_ = false;
}

- (void) releaseSubviews {
    webview_ = nil;
    scroller_ = nil;

    [self releaseNetworkActivityIndicator];

    [super releaseSubviews];
}

- (id) initWithWidth:(float)width {
    return [self initWithWidth:width ofClass:[self class]];
}

- (id) init {
    return [self initWithWidth:0];
}

- (id) initWithURL:(NSURL *)url {
    if ((self = [self init]) != nil) {
        [self setURL:url];
    } return self;
}

- (id) initWithRequest:(NSURLRequest *)request {
    if ((self = [self init]) != nil) {
        [self setRequest:request];
    } return self;
}

+ (void) _lockJavaScript:(WebPreferences *)preferences {
    WebThreadLocked lock;
    [preferences setJavaScriptCanOpenWindowsAutomatically:NO];
}

- (void) callFunction:(WebScriptObject *)function {
    WebThreadLocked lock;

    WebView *webview([[[self webView] _documentView] webView]);
    WebPreferences *preferences([webview preferences]);

    [preferences setJavaScriptCanOpenWindowsAutomatically:YES];
    if ([webview respondsToSelector:@selector(_preferencesChanged:)])
        [webview _preferencesChanged:preferences];
    else
        [webview _preferencesChangedNotification:[NSNotification notificationWithName:@"" object:preferences]];

    WebFrame *frame([webview mainFrame]);
    JSGlobalContextRef context([frame globalContext]);

    JSObjectRef object([function JSObject]);
    if ($JSObjectCallAsFunction != NULL)
        ($JSObjectCallAsFunction)(context, object, NULL, 0, NULL, NULL);

    // XXX: the JavaScript code submits a form, which seems to happen asynchronously
    NSObject *target([CyteWebViewController class]);
    [NSObject cancelPreviousPerformRequestsWithTarget:target selector:@selector(_lockJavaScript:) object:preferences];
    [target performSelector:@selector(_lockJavaScript:) withObject:preferences afterDelay:1];
}

- (void) reloadButtonClicked {
    [self reloadURLWithCache:NO];
}

- (void) _customButtonClicked {
    [self reloadButtonClicked];
}

- (void) customButtonClicked {
#if !AlwaysReload
    if (function_ != nil)
        [self callFunction:function_];
    else
#endif
    [self _customButtonClicked];
}

+ (float) defaultWidth {
    return 980;
}

- (void) setNavigationBarStyle:(NSString *)name {
    UIBarStyle style;
    if ([name isEqualToString:@"Black"])
        style = UIBarStyleBlack;
    else
        style = UIBarStyleDefault;

    [[[self navigationController] navigationBar] setBarStyle:style];
}

- (void) setNavigationBarTintColor:(UIColor *)color {
    [[[self navigationController] navigationBar] setTintColor:color];
}

- (void) setBadgeValue:(id)value {
    [[[self navigationController] tabBarItem] setBadgeValue:value];
}

- (void) setHidesBackButton:(bool)value {
    [[self navigationItem] setHidesBackButton:value];
    [self applyLeftButton];
}

- (void) setHidesBackButtonByNumber:(NSNumber *)value {
    [self setHidesBackButton:[value boolValue]];
}

- (void) dispatchEvent:(NSString *)event {
    [[self webView] dispatchEvent:event];
}

- (bool) hidesNavigationBar {
    return hidesNavigationBar_;
}

- (void) _setHidesNavigationBar:(bool)value animated:(bool)animated {
    if (visible_)
        [[self navigationController] setNavigationBarHidden:(value && [self hidesNavigationBar]) animated:animated];
}

- (void) setHidesNavigationBar:(bool)value {
    if (hidesNavigationBar_ != value) {
        hidesNavigationBar_ = value;
        [self _setHidesNavigationBar:YES animated:YES];
    }
}

- (void) setHidesNavigationBarByNumber:(NSNumber *)value {
    [self setHidesNavigationBar:[value boolValue]];
}

- (void) setScrollAlwaysBounceVertical:(bool)value {
    if ([webview_ respondsToSelector:@selector(_scrollView)]) {
        UIScrollView *scroller([webview_ _scrollView]);
        [scroller setAlwaysBounceVertical:value];
    } else if ([webview_ respondsToSelector:@selector(_scroller)]) {
        //UIScroller *scroller([webview_ _scroller]);
        // XXX: I am sad here.
    } else return;
}

- (void) setScrollAlwaysBounceVerticalNumber:(NSNumber *)value {
    [self setScrollAlwaysBounceVertical:[value boolValue]];
}

- (void) setScrollIndicatorStyle:(UIScrollViewIndicatorStyle)style {
    if ([webview_ respondsToSelector:@selector(_scrollView)]) {
        UIScrollView *scroller([webview_ _scrollView]);
        [scroller setIndicatorStyle:style];
    } else if ([webview_ respondsToSelector:@selector(_scroller)]) {
        UIScroller *scroller([webview_ _scroller]);
        [scroller setScrollerIndicatorStyle:style];
    } else return;
}

- (void) setScrollIndicatorStyleWithName:(NSString *)style {
    UIScrollViewIndicatorStyle value;

    if (false);
    else if ([style isEqualToString:@"default"])
        value = UIScrollViewIndicatorStyleDefault;
    else if ([style isEqualToString:@"black"])
        value = UIScrollViewIndicatorStyleBlack;
    else if ([style isEqualToString:@"white"])
        value = UIScrollViewIndicatorStyleWhite;
    else return;

    [self setScrollIndicatorStyle:value];
}

- (void) viewWillAppear:(BOOL)animated {
    visible_ = true;

    if ([self hidesNavigationBar])
        [self _setHidesNavigationBar:YES animated:animated];

    // XXX: why isn't this evern called automatically?
    [[self webView] setNeedsLayout];

    [self dispatchEvent:@"CydiaViewWillAppear"];
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self dispatchEvent:@"CydiaViewDidAppear"];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self dispatchEvent:@"CydiaViewWillDisappear"];
    [super viewWillDisappear:animated];

    if ([self hidesNavigationBar])
        [self _setHidesNavigationBar:NO animated:animated];

    visible_ = false;
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self dispatchEvent:@"CydiaViewDidDisappear"];
}

- (void) updateHeights:(NSTimer *)timer {
    for (WebFrame *frame in (id) registered_)
        [frame cydia$updateHeight];
}

- (void) registerFrame:(WebFrame *)frame {
    [registered_ addObject:frame];

    if (timer_ == nil)
        timer_ = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateHeights:) userInfo:nil repeats:YES];
}

@end

MSClassHook(WAKWindow)

static CGSize $WAKWindow$screenSize(WAKWindow *self, SEL _cmd) {
    CGSize size([[UIScreen mainScreen] bounds].size);
    /*if ([$WAKWindow respondsToSelector:@selector(hasLandscapeOrientation)])
        if ([$WAKWindow hasLandscapeOrientation])
            std::swap(size.width, size.height);*/
    return size;
}

static struct WAKWindow$screenSize { WAKWindow$screenSize() {
    if ($WAKWindow != NULL)
        if (Method method = class_getInstanceMethod($WAKWindow, @selector(screenSize)))
            method_setImplementation(method, (IMP) &$WAKWindow$screenSize);
} } WAKWindow$screenSize;;

MSClassHook(NSUserDefaults)

MSHook(id, NSUserDefaults$objectForKey$, NSUserDefaults *self, SEL _cmd, NSString *key) {
    if ([key respondsToSelector:@selector(isEqualToString:)] && [key isEqualToString:@"WebKitLocalStorageDatabasePathPreferenceKey"])
        return [NSString stringWithFormat:@"%@/%@/%@", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject, NSBundle.mainBundle.bundleIdentifier, @"LocalStorage"];
    return _NSUserDefaults$objectForKey$(self, _cmd, key);
}

CYHook(NSUserDefaults, objectForKey$, objectForKey:)
