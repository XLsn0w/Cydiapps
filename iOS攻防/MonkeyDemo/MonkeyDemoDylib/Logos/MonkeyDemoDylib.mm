#line 1 "/Users/zhihuishequ/Desktop/iOSRETest/MonkeyDemo/MonkeyDemoDylib/Logos/MonkeyDemoDylib.xm"


#import <UIKit/UIKit.h>

@interface  ViewController

@property (nonatomic, copy) NSString* newProperty;

+ (void)classMethod;

- (NSString*)getMyName;

- (void)newMethod:(NSString*) output;
- (void)btnClick2:(id) org;


@end


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class ViewController; @class CustomViewController; 
static void (*_logos_meta_orig$_ungrouped$ViewController$classMethod)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static void _logos_meta_method$_ungrouped$ViewController$classMethod(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$ViewController$btnClick2$)(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$ViewController$btnClick2$(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$ViewController$newMethod$(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL, NSString*); static id _logos_method$_ungrouped$ViewController$newProperty(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$ViewController$setNewProperty$(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL, id); static NSString* (*_logos_orig$_ungrouped$ViewController$getMyName)(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL); static NSString* _logos_method$_ungrouped$ViewController$getMyName(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST, SEL); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$CustomViewController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("CustomViewController"); } return _klass; }
#line 19 "/Users/zhihuishequ/Desktop/iOSRETest/MonkeyDemo/MonkeyDemoDylib/Logos/MonkeyDemoDylib.xm"



static void _logos_meta_method$_ungrouped$ViewController$classMethod(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	HBLogDebug(@"+[<ViewController: %p> classMethod]", self);

	_logos_meta_orig$_ungrouped$ViewController$classMethod(self, _cmd);
}


static void _logos_method$_ungrouped$ViewController$btnClick2$(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id org) {
    NSLog(@"MonkeyDev Hook 成功了!🍺🍺🍺🍺");
}


static void _logos_method$_ungrouped$ViewController$newMethod$(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString* output){
    NSLog(@"This is a new method : %@", output);
}


static id _logos_method$_ungrouped$ViewController$newProperty(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    return objc_getAssociatedObject(self, @selector(newProperty));
}


static void _logos_method$_ungrouped$ViewController$setNewProperty$(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id value) {
    objc_setAssociatedObject(self, @selector(newProperty), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static NSString* _logos_method$_ungrouped$ViewController$getMyName(_LOGOS_SELF_TYPE_NORMAL ViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	HBLogDebug(@"-[<ViewController: %p> getMyName]", self);
    
    NSString* password = MSHookIvar<NSString*>(self,"_password");
    
    NSLog(@"password:%@", password);
    
    [_logos_static_class_lookup$CustomViewController() classMethod];
    
    [self newMethod:@"output"];
    
    self.newProperty = @"newProperty";
    
    NSLog(@"newProperty : %@", self.newProperty);

	return _logos_orig$_ungrouped$ViewController$getMyName(self, _cmd);
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$ViewController = objc_getClass("ViewController"); Class _logos_metaclass$_ungrouped$ViewController = object_getClass(_logos_class$_ungrouped$ViewController); MSHookMessageEx(_logos_metaclass$_ungrouped$ViewController, @selector(classMethod), (IMP)&_logos_meta_method$_ungrouped$ViewController$classMethod, (IMP*)&_logos_meta_orig$_ungrouped$ViewController$classMethod);MSHookMessageEx(_logos_class$_ungrouped$ViewController, @selector(btnClick2:), (IMP)&_logos_method$_ungrouped$ViewController$btnClick2$, (IMP*)&_logos_orig$_ungrouped$ViewController$btnClick2$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSString*), strlen(@encode(NSString*))); i += strlen(@encode(NSString*)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$ViewController, @selector(newMethod:), (IMP)&_logos_method$_ungrouped$ViewController$newMethod$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$ViewController, @selector(newProperty), (IMP)&_logos_method$_ungrouped$ViewController$newProperty, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$ViewController, @selector(setNewProperty:), (IMP)&_logos_method$_ungrouped$ViewController$setNewProperty$, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$ViewController, @selector(getMyName), (IMP)&_logos_method$_ungrouped$ViewController$getMyName, (IMP*)&_logos_orig$_ungrouped$ViewController$getMyName);} }
#line 68 "/Users/zhihuishequ/Desktop/iOSRETest/MonkeyDemo/MonkeyDemoDylib/Logos/MonkeyDemoDylib.xm"
