#ifndef CYDIA_UIKITPRIVATE_H
#define CYDIA_UIKITPRIVATE_H

// #include <*> {{{
#include <JavaScriptCore/JavaScriptCore.h>
#include <UIKit/UIKit.h>
// }}}
// typedef GS* {{{
typedef struct __GSEvent *GSEventRef;
// }}}

// enum UI* {{{
typedef enum {
    UIGestureAttributeMinDegrees,                 /*float*/
    UIGestureAttributeMaxDegrees,                 /*float*/
    UIGestureAttributeMinScale,                   /*float*/
    UIGestureAttributeMaxScale,                   /*float*/
    UIGestureAttributeIsZoomRubberBandEnabled,    /*BOOL*/
    UIGestureAttributeZoomsFromCurrentToMinOrMax, /*BOOL*/
    UIGestureAttributeVisibleSize,                /*CGSize*/
    UIGestureAttributeUpdatesScroller,            /*BOOL*/
} UIGestureAttribute;

typedef enum {
    UINavigationButtonStyleNormal,
    UINavigationButtonStyleBack,
    UINavigationButtonStyleHighlighted,
    UINavigationButtonStyleDestructive
} UINavigationButtonStyle;

static const UIActivityIndicatorViewStyle UIActivityIndicatorViewStyleWhiteSmall(static_cast<UIActivityIndicatorViewStyle>(3));
static const UIActivityIndicatorViewStyle UIActivityIndicatorViewStyleGraySmall(static_cast<UIActivityIndicatorViewStyle>(4));
static const UIActivityIndicatorViewStyle UIActivityIndicatorViewStyleWhiteTiny(static_cast<UIActivityIndicatorViewStyle>(5));
// }}}
// #define * * {{{
#define UIDataDetectorTypeAutomatic 0x80000000
// }}}

// @class DOM*; {{{
@class DOMRGBColor;
// }}}
// @class Web*; {{{
@class WebScriptObject;
@class WebView;
// }}}

// enum DOM_* {{{
enum {
    DOM_CSS_UNKNOWN = 0,
    DOM_CSS_NUMBER = 1,
    DOM_CSS_PERCENTAGE = 2,
    DOM_CSS_EMS = 3,
    DOM_CSS_EXS = 4,
    DOM_CSS_PX = 5,
    DOM_CSS_CM = 6,
    DOM_CSS_MM = 7,
    DOM_CSS_IN = 8,
    DOM_CSS_PT = 9,
    DOM_CSS_PC = 10,
    DOM_CSS_DEG = 11,
    DOM_CSS_RAD = 12,
    DOM_CSS_GRAD = 13,
    DOM_CSS_MS = 14,
    DOM_CSS_S = 15,
    DOM_CSS_HZ = 16,
    DOM_CSS_KHZ = 17,
    DOM_CSS_DIMENSION = 18,
    DOM_CSS_STRING = 19,
    DOM_CSS_URI = 20,
    DOM_CSS_IDENT = 21,
    DOM_CSS_ATTR = 22,
    DOM_CSS_COUNTER = 23,
    DOM_CSS_RECT = 24,
    DOM_CSS_RGBCOLOR = 25,
    DOM_CSS_VW = 26,
    DOM_CSS_VH = 27,
    DOM_CSS_VMIN = 28,
    DOM_CSS_VMAX = 29
};
// }}}
// enum Web* {{{
typedef NS_ENUM(NSUInteger, WebCacheModel) {
    WebCacheModelDocumentViewer = 0,
    WebCacheModelDocumentBrowser = 1,
    WebCacheModelPrimaryWebBrowser = 2
};

typedef enum {
    WebEventMouseDown,
    WebEventMouseUp,
    WebEventMouseMoved,
    WebEventScrollWheel,
    WebEventKeyDown,
    WebEventKeyUp,
    WebEventTouchBegin,
    WebEventTouchChange,
    WebEventTouchEnd,
    WebEventTouchCancel
} WebEventType;

enum {
    WebKitErrorCannotShowMIMEType = 100,
    WebKitErrorCannotShowURL = 101,
    WebKitErrorFrameLoadInterruptedByPolicyChange = 102,
};
// }}}
// @protocol Web*; {{{
@protocol WebPolicyDecisionListener <NSObject>
- (void) use;
- (void) download;
- (void) ignore;
@end
// }}}

// @interface * : UIView {{{
@interface UIFormAssistant : UIView
+ (UIFormAssistant *) sharedFormAssistant;
- (CGRect) peripheralFrame;
@end

@interface UIKeyboard : UIView
+ (void) initImplementationNow;
@end

@interface UIProgressBar : UIView
+ (CGSize) defaultSize;
- (void) setProgress:(float)progress;
- (void) setStyle:(NSInteger)style;
@end

@interface UIProgressHUD : UIView
- (void) hide;
- (void) setText:(NSString *)text;
- (void) showInView:(UIView *)view;
@end

@interface UIScroller : UIView
- (CGSize) contentSize;
- (void) setDirectionalScrolling:(BOOL)directional;
- (void) setEventMode:(NSInteger)mode;
- (void) setOffset:(CGPoint)offset;
- (void) setScrollDecelerationFactor:(CGFloat)factor;
- (void) setScrollHysteresis:(CGFloat)hysteresis;
- (void) setScrollerIndicatorStyle:(UIScrollViewIndicatorStyle)style;
- (void) setThumbDetectionEnabled:(BOOL)enabled;
@end

@interface UITextLabel : UIView
- (void) setCentersHorizontally:(BOOL)centers;
- (void) setColor:(UIColor *)color;
- (void) setFont:(UIFont *)font;
- (void) setText:(NSString *)text;
@end

@interface UITransitionView : UIView
@end

@interface UIWebDocumentView : UIView
- (CGRect) documentBounds;
- (void) enableReachability;
- (void) loadRequest:(NSURLRequest *)request;
- (void) redrawScaledDocument;
- (void) setAllowsImageSheet:(BOOL)allows;
- (void) setAllowsMessaging:(BOOL)allows;
- (void) setAutoresizes:(BOOL)autoresizes;
- (void) setContentsPosition:(NSInteger)position;
- (void) setDrawsBackground:(BOOL)draws;
- (void) _setDocumentType:(NSInteger)type;
- (void) setDrawsGrid:(BOOL)draws;
- (void) setInitialScale:(float)scale forDocumentTypes:(NSInteger)types;
- (void) setLogsTilingChanges:(BOOL)logs;
- (void) setMinimumScale:(float)scale forDocumentTypes:(NSInteger)types;
- (void) setMinimumSize:(CGSize)size;
- (void) setMaximumScale:(float)scale forDocumentTypes:(NSInteger)tpyes;
- (void) setSmoothsFonts:(BOOL)smooths;
- (void) setTileMinificationFilter:(NSString *)filter;
- (void) setTileSize:(CGSize)size;
- (void) setTilingEnabled:(BOOL)enabled;
- (void) setViewportSize:(CGSize)size forDocumentTypes:(NSInteger)types;
- (void) setZoomsFocusedFormControl:(BOOL)zooms;
- (void) useSelectionAssistantWithMode:(NSInteger)mode;
- (WebView *) webView;
@end

@interface UIWebViewWebViewDelegate : NSObject {
    @public UIWebView *uiWebView;
}

- (void) _clearUIWebView;

@end
// }}}
// @interface *Button : * {{{
@interface UINavigationButton : UIButton
- (id) initWithTitle:(NSString *)title style:(UINavigationButtonStyle)style;
- (void) setBarStyle:(UIBarStyle)style;
@end

@interface UIPushButton : UIControl
- (id) backgroundForState:(NSUInteger)state;
- (void) setAutosizesToFit:(BOOL)autosizes;
- (void) setBackground:(id)background forState:(NSUInteger)state;
- (void) setDrawsShadow:(BOOL)draws;
- (void) setStretchBackground:(BOOL)stretch;
- (void) setTitle:(NSString *)title;
- (void) setTitleFont:(UIFont *)font;
@end

@interface UIThreePartButton : UIPushButton
@end
// }}}
// @interface * : NS* {{{
@interface WebDefaultUIKitDelegate : NSObject
+ (WebDefaultUIKitDelegate *) sharedUIKitDelegate;
@end
// }}}
// @interface DOM* {{{
@interface DOMObject
@end

@interface DOMCSSValue : DOMObject
@end

@interface DOMCSSPrimitiveValue : DOMCSSValue
@property (readonly) unsigned short primitiveType;
- (DOMRGBColor *) getRGBColorValue;
- (float) getFloatValue:(unsigned short)unit;
@end

@interface DOMRGBColor : DOMObject
@property (readonly, strong) DOMCSSPrimitiveValue *red;
@property (readonly, strong) DOMCSSPrimitiveValue *green;
@property (readonly, strong) DOMCSSPrimitiveValue *blue;
@property (readonly, strong) DOMCSSPrimitiveValue *alpha;
@end

@interface DOMCSSStyleDeclaration : DOMObject
- (DOMCSSValue *) getPropertyCSSValue:(NSString *)name;
- (void) setProperty:(NSString *)name value:(NSString *)value priority:(NSString *)priority;
@end

@interface DOMNode : DOMObject
@end

@interface DOMNodeList : DOMObject
@property (readonly) unsigned length;
- (DOMNode *) item:(unsigned)index;
@end

@interface DOMElement : DOMNode
@property (readonly) int scrollHeight;
@end

@interface DOMHTMLElement : DOMElement
@property (readonly, strong) DOMCSSStyleDeclaration *style;
@end

@interface DOMHTMLBodyElement : DOMHTMLElement
@end

@interface DOMHTMLIFrameElement : DOMHTMLElement
@end

@interface DOMDocument : DOMNode
@property (strong) DOMHTMLElement *body;
- (DOMCSSStyleDeclaration *) getComputedStyle:(DOMElement *)element pseudoElement:(NSString *)pseudo;
- (DOMNodeList *) getElementsByTagName:(NSString *)name;
@end
// }}}
// @interface WAK* : * {{{
@interface WAKResponder : NSObject
@end

@interface WAKView : NSObject
+ (BOOL) hasLandscapeOrientation;
@end

@interface WAKWindow : NSObject
+ (BOOL) hasLandscapeOrientation;
@end
// }}}
// @interface Web* {{{
@interface WebPreferences : NSObject
- (void) setCacheModel:(WebCacheModel)value;
- (void) setJavaScriptCanOpenWindowsAutomatically:(BOOL)value;
@end

@interface WebDataSource : NSObject
- (NSURLRequest *) request;
- (NSURLResponse *) response;
@end

@interface WebFrame : NSObject
@property (nonatomic, readonly, copy) NSArray *childFrames;
@property (nonatomic, readonly, strong) WebDataSource *dataSource;
@property (nonatomic, readonly, strong) DOMDocument *DOMDocument;
@property (nonatomic, readonly, strong) DOMHTMLElement *frameElement;
@property (nonatomic, readonly) JSGlobalContextRef globalContext;
@property (nonatomic, readonly, strong) WebFrame *parentFrame;
@property (nonatomic, readonly, strong) WebDataSource *provisionalDataSource;
@property (nonatomic, readonly, strong) WebScriptObject *windowObject;
@end

@interface WebView : WAKView
@property (nonatomic, readonly, strong) WebFrame *mainFrame;
@property (nonatomic, strong) WebPreferences *preferences;
- (IBAction) reloadFromOrigin:(id)sender;
- (void) setApplicationNameForUserAgent:(NSString *)value;
- (void) setShouldUpdateWhileOffscreen:(BOOL)value;
@end

@interface WebScriptObject : NSObject
- (id) evaluateWebScript:(NSString *)script;
+ (BOOL) isKeyExcludedFromWebScript:(const char *)name;
- (JSObjectRef) JSObject;
- (void) setWebScriptValueAtIndex:(unsigned)index value:(id)value;
- (id) webScriptValueAtIndex:(unsigned)index;
@end

@interface WebUndefined : NSObject
+ (WebUndefined *) undefined;
@end
// }}}
// @interface UIWeb* : * {{{
@interface UIWebBrowserView : UIWebDocumentView
@end

@interface UIWebTouchEventsGestureRecognizer : UIGestureRecognizer
- (int) type;
- (NSString *) _typeDescription;
@end
// }}}

// @interface NS* (*) {{{
@interface NSMutableURLRequest (Apple)
- (void) setHTTPShouldUsePipelining:(BOOL)pipelining;
@end

@interface NSObject (Apple)
+ (BOOL) isKeyExcludedFromWebScript:(const char *)name;
- (NSArray *) attributeKeys;
@end

@interface NSString (Apple)
- (NSString *) stringByAddingPercentEscapes;
- (NSString *) stringByReplacingCharacter:(UniChar)from withCharacter:(UniChar)to;
@end

@interface NSURL (Apple)
- (BOOL) isGoogleMapsURL;
- (BOOL) isSpringboardHandledURL;
// XXX: make this an enum
- (NSURL *) itmsURL:(NSInteger *)store;
- (NSURL *) mapsURL;
- (NSURL *) phobosURL;
- (NSURL *) youTubeURL;
@end

@interface NSURLRequest (Apple)
+ (BOOL) allowsAnyHTTPSCertificateForHost:(NSString *)host;
+ (void) setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end

@interface NSValue (Apple)
+ (NSValue *) valueWithSize:(CGSize)size;
@end
// }}}
// @interface UI* (*) {{{
@interface UIActionSheet (Apple)
- (void) setContext:(NSString *)context;
- (NSString *) context;
@end

@interface UIAlertView (Apple)
- (void) addTextFieldWithValue:(NSString *)value label:(NSString *)label;
- (id) buttons;
- (NSString *) context;
- (void) setContext:(NSString *)context;
- (void) setNumberOfRows:(int)rows;
- (void) setRunsModal:(BOOL)modal;
- (UITextField *) textField;
- (UITextField *) textFieldAtIndex:(NSUInteger)index;
- (void) _updateFrameForDisplay;
@end

@interface UIApplication (Apple)
- (void) suspendReturningToLastApp:(BOOL)returning;
- (void) suspend;
- (void) applicationSuspend;
- (void) applicationSuspend:(GSEventRef)event;
- (void) _animateSuspension:(BOOL)suspend duration:(double)duration startTime:(double)start scale:(float)scale;
- (void) applicationOpenURL:(NSURL *)url;
- (void) applicationWillResignActive:(UIApplication *)application;
- (void) applicationWillSuspend;
- (void) launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
- (void) openURL:(NSURL *)url asPanel:(BOOL)panel;
- (void) setStatusBarShowsProgress:(BOOL)shows;
- (void) _setSuspended:(BOOL)suspended;
- (void) terminateWithSuccess;
@end

@interface UIBarButtonItem (Apple)
- (UIView *) view;
@end

@interface UIColor (Apple)
+ (UIColor *) pinStripeColor;
@end

@interface UIControl (Apple)
- (void) addTarget:(id)target action:(SEL)action forEvents:(NSInteger)events;
@end

@interface UIDevice (Apple)
- (NSString *) uniqueIdentifier;
@end

@interface UIImage (Apple)
+ (UIImage *) imageAtPath:(NSString *)path;
@end

@interface UILocalizedIndexedCollation (Apple)
- (id) initWithDictionary:(NSDictionary *)dictionary;
- (NSString *) transformedCollationStringForString:(NSString *)string;
@end

@interface UINavigationBar (Apple)
+ (CGSize) defaultSize;
- (UIBarStyle) _barStyle:(BOOL)style;
@end

@interface UIScrollView (Apple)
- (void) setScrollingEnabled:(BOOL)enabled;
- (void) setShowBackgroundShadow:(BOOL)show;
@end

@interface UISearchBar (Apple)
- (UITextField *) searchField;
@end

@interface UITabBarController (Apple)
- (UITransitionView *) _transitionView;
- (void) concealTabBarSelection;
- (void) revealTabBarSelection;
@end

@interface UITabBarItem (Apple)
- (void) setAnimatedBadge:(BOOL)animated;
- (UIView *) view;
@end

@interface UITableViewCell (Apple)
- (float) selectionPercent;
- (void) _updateHighlightColorsForView:(id)view highlighted:(BOOL)highlighted;
@end

@interface UITextField (Apple)
- (NSObject<UITextInputTraits> *) textInputTraits;
@end

@interface UITextView (Apple)
- (UIFont *) font;
- (void) setAllowsRubberBanding:(BOOL)rubberbanding;
- (void) setFont:(UIFont *)font;
- (void) setMarginTop:(int)margin;
- (void) setTextColor:(UIColor *)color;
@end

@interface UIView (Apple)
- (UIScroller *) _scroller;
- (void) setClipsSubviews:(BOOL)clips;
- (void) setEnabledGestures:(NSInteger)gestures;
- (void) setFixedBackgroundPattern:(BOOL)fixed;
- (void) setGestureDelegate:(id)delegate;
- (void) setNeedsDisplayOnBoundsChange:(BOOL)needs;
- (void) setValue:(NSValue *)value forGestureAttribute:(NSInteger)attribute;
- (void) setZoomScale:(float)scale duration:(double)duration;
- (void) _setZoomScale:(float)scale duration:(double)duration;
- (void) setOrigin:(CGPoint)origin;
@end

@interface UIViewController (Apple)
- (void) _updateLayoutForStatusBarAndInterfaceOrientation;
- (void) unloadView;
@end

@interface UIWindow (Apple)
- (UIResponder *) firstResponder;
- (void) makeKey:(UIApplication *)application;
- (void) orderFront:(UIApplication *)application;
@end

@interface UIWebView (Apple)
- (UIWebDocumentView *) _documentView;
- (UIScrollView *) _scrollView;
- (UIScroller *) _scroller;
- (void) _updateViewSettings;
- (void) webView:(WebView *)view addMessageToConsole:(NSDictionary *)message;
//- (WebView *) webView:(WebView *)view createWebViewWithRequest:(NSURLRequest *)request;
- (void) webView:(WebView *)view decidePolicyForNavigationAction:(NSDictionary *)action request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener;
- (void) webView:(WebView *)view decidePolicyForNewWindowAction:(NSDictionary *)action request:(NSURLRequest *)request newFrameName:(NSString *)name decisionListener:(id<WebPolicyDecisionListener>)listener;
- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame;
- (void) webView:(WebView *)view didCommitLoadForFrame:(WebFrame *)frame;
- (void) webView:(WebView *)view didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;
- (void) webView:(WebView *)view didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;
- (void) webView:(WebView *)view didFinishLoadForFrame:(WebFrame *)frame;
- (void) webView:(WebView *)view didReceiveTitle:(id)title forFrame:(id)frame;
- (void) webView:(WebView *)view didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void) webView:(WebView *)view resource:(id)identifier didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)source;
- (void) webView:(WebView *)view resource:(id)identifier didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge fromDataSource:(WebDataSource *)source;
- (NSURLRequest *) webView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source;
- (NSURLRequest *) webThreadWebView:(WebView *)view resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source;
- (void) webView:(WebView *)view runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (BOOL) webView:(WebView *)view runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (NSString *) webView:(WebView *)view runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)text initiatedByFrame:(WebFrame *)frame;
- (void) webViewClose:(WebView *)view;
@end
// }}}
// @interface Web* (*) {{{
@interface WebFrame (Apple)
- (void) setNeedsLayout;
@end

@interface WebPreferences (Apple)
+ (void) _setInitialDefaultTextEncodingToSystemEncoding;
- (void) _setLayoutInterval:(NSInteger)interval;
- (void) setOfflineWebApplicationCacheEnabled:(BOOL)enabled;
@end

@interface WebView (Apple)
- (void) _preferencesChanged:(WebPreferences *)preferences;
- (void) _preferencesChangedNotification:(NSNotification *)notification;
- (void) _setLayoutInterval:(float)interval;
- (void) _setAllowsMessaging:(BOOL)allows;
@end
// }}}

// #ifndef AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER {{{
#ifndef AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER
#define AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER
// XXX: this is a random jumble of garbage

typedef enum {
    UIModalPresentationFullScreen,
    UIModalPresentationPageSheet,
    UIModalPresentationFormSheet,
    UIModalPresentationCurrentContext,
} UIModalPresentationStyle;

#define kSCNetworkReachabilityFlagsConnectionOnTraffic kSCNetworkReachabilityFlagsConnectionAutomatic

#define UIBarStyleBlack UIBarStyleBlackOpaque

@class NSUndoManager;
@class UIPasteboard;

@interface UIActionSheet (iPad)
- (void) showFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
@end

@interface UIViewController (iPad)
- (void) setModalPresentationStyle:(UIModalPresentationStyle)style;
@end

@interface UIApplication (iOS_3_0)
@property(nonatomic) BOOL applicationSupportsShakeToEdit;
@end

@interface UIScrollView (iOS_3_0)
@property(assign,nonatomic) CGFloat decelerationRate;
@end

@interface UIWebView (iOS_3_0)
@property(assign,nonatomic) NSUInteger dataDetectorTypes;
@end

extern CGFloat const UIScrollViewDecelerationRateNormal;

#endif//AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER
// }}}
// #if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000 {{{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000

#define kSCNetworkReachabilityFlagsConnectionOnDemand (1 << 5)
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47

#endif
// }}}

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

@interface UITabBarItem (iOS_7_0)
- (id) initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
@end

@interface UIScreen (iOS_4_0)
@property(nonatomic,readonly) CGFloat scale;
@end

@interface DOMHTMLIFrameElement (IDL)
- (WebFrame *) contentFrame;
@end

// extern *; {{{
extern CFStringRef const kGSDisplayIdentifiersCapability;
extern float const UIWebViewGrowsAndShrinksToFitHeight;
extern float const UIWebViewScalesToFitScale;
extern NSString *WebKitErrorDomain;
// }}}
// extern "C" *(); {{{
extern "C" void *reboot2(uint64_t flags);
extern "C" mach_port_t SBSSpringBoardServerPort();
extern "C" int SBBundlePathForDisplayIdentifier(mach_port_t port, const char *identifier, char *path);
extern "C" NSArray *SBSCopyApplicationDisplayIdentifiers(bool active, bool debuggable);
extern "C" NSString *SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *);
extern "C" NSString *SBSCopyIconImagePathForDisplayIdentifier(NSString *);
extern "C" UIImage *_UIImageWithName(NSString *name);
extern "C" void UISetColor(CGColorRef color);
// }}}

#endif//CYDIA_UIKITPRIVATE_H
