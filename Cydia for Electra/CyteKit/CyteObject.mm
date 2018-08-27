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

#include <sys/mount.h>
#include <sys/sysctl.h>

#include <IOKit/IOKitLib.h>
#include <objc/runtime.h>

#include "CyteKit/CyteObject.h"
#include "CyteKit/WebViewController.h"
#include "CyteKit/countByEnumeratingWithState.h"
#include "CyteKit/extern.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

@implementation NSDictionary (Cydia)
- (id) invokeUndefinedMethodFromWebScript:(NSString *)name withArguments:(NSArray *)arguments {
    if (false);
    else if ([name isEqualToString:@"get"])
        return [self objectForKey:[arguments objectAtIndex:0]];
    else if ([name isEqualToString:@"keys"])
        return [self allKeys];
    return nil;
} @end

static NSString *CYHex(NSData *data, bool reverse = false) {
    if (data == nil)
        return nil;

    size_t length([data length]);
    uint8_t bytes[length];
    [data getBytes:bytes];

    char string[length * 2 + 1];
    for (size_t i(0); i != length; ++i)
        sprintf(string + i * 2, "%.2x", bytes[reverse ? length - i - 1 : i]);

    return [NSString stringWithUTF8String:string];
}

static NSObject *CYIOGetValue(const char *path, NSString *property) {
    io_registry_entry_t entry(IORegistryEntryFromPath(kIOMasterPortDefault, path));
    if (entry == MACH_PORT_NULL)
        return nil;

    CFTypeRef value(IORegistryEntryCreateCFProperty(entry, (CFStringRef) property, kCFAllocatorDefault, 0));
    IOObjectRelease(entry);

    if (value == NULL)
        return nil;
    return [(id) value autorelease];
}

@implementation CyteObject {
    _H<CyteWebViewController> indirect_;
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return false;
}

- (id) initWithDelegate:(CyteWebViewController *)indirect {
    if ((self = [super init]) != nil) {
        indirect_ = indirect;
    } return self;
}


- (NSArray *) attributeKeys {
    return [NSArray arrayWithObjects:
        @"bbsnum",
        @"bittage",
        @"build",
        @"coreFoundationVersionNumber",
        @"ecid",
        @"firmware",
        @"hostname",
        @"idiom",
        @"model",
        @"serial",
    nil];
}

- (unsigned) bittage {
#if 0
#elif defined(__arm64__)
    return 64;
#elif defined(__arm__)
    return 32;
#else
    return 0;
#endif
}

- (NSString *) bbsnum {
    return (id) CYHex((NSData *) CYIOGetValue("IOService:/AppleARMPE/baseband", @"snum"), false) ?: [NSNull null];
}

- (NSString *) build {
    return [NSString stringWithUTF8String:System_];
}

- (NSString *) coreFoundationVersionNumber {
    return [NSString stringWithFormat:@"%.2f", kCFCoreFoundationVersionNumber];
}

- (NSString *) ecid {
    return (id) [CYHex((NSData *) CYIOGetValue("IODeviceTree:/chosen", @"unique-chip-id"), true) uppercaseString] ?: [NSNull null];
}

- (NSString *) firmware {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *) hostname {
    return [[UIDevice currentDevice] name];
}

- (NSString *) idiom {
    return IsWildcat_ ? @"ipad" : @"iphone";
}

- (NSString *) model {
    return [NSString stringWithUTF8String:Machine_];
}

- (NSString *) serial {
    return (NSString *) CYIOGetValue("IOService:/", @"IOPlatformSerialNumber");
}


+ (NSString *) webScriptNameForSelector:(SEL)selector {
    if (false);
    else if (selector == @selector(addInternalRedirect::))
        return @"addInternalRedirect";
    else if (selector == @selector(close))
        return @"close";
    else if (selector == @selector(stringWithFormat:arguments:))
        return @"format";
    else if (selector == @selector(getIORegistryEntry::))
        return @"getIORegistryEntry";
    else if (selector == @selector(getKernelNumber:))
        return @"getKernelNumber";
    else if (selector == @selector(getKernelString:))
        return @"getKernelString";
    else if (selector == @selector(getLocaleIdentifier))
        return @"getLocaleIdentifier";
    else if (selector == @selector(getPreferredLanguages))
        return @"getPreferredLanguages";
    else if (selector == @selector(isReachable:))
        return @"isReachable";
    else if (selector == @selector(localizedStringForKey:value:table:))
        return @"localize";
    else if (selector == @selector(popViewController:))
        return @"popViewController";
    else if (selector == @selector(registerFrame:))
        return @"registerFrame";
    else if (selector == @selector(removeButton))
        return @"removeButton";
    else if (selector == @selector(scrollToBottom:))
        return @"scrollToBottom";
    else if (selector == @selector(setAllowsNavigationAction:))
        return @"setAllowsNavigationAction";
    else if (selector == @selector(setBadgeValue:))
        return @"setBadgeValue";
    else if (selector == @selector(setButtonImage:withStyle:toFunction:))
        return @"setButtonImage";
    else if (selector == @selector(setButtonTitle:withStyle:toFunction:))
        return @"setButtonTitle";
    else if (selector == @selector(setHidesBackButton:))
        return @"setHidesBackButton";
    else if (selector == @selector(setHidesNavigationBar:))
        return @"setHidesNavigationBar";
    else if (selector == @selector(setNavigationBarStyle:))
        return @"setNavigationBarStyle";
    else if (selector == @selector(setNavigationBarTintRed:green:blue:alpha:))
        return @"setNavigationBarTintColor";
    else if (selector == @selector(setPasteboardString:))
        return @"setPasteboardString";
    else if (selector == @selector(setPasteboardURL:))
        return @"setPasteboardURL";
    else if (selector == @selector(setScrollAlwaysBounceVertical:))
        return @"setScrollAlwaysBounceVertical";
    else if (selector == @selector(setScrollIndicatorStyle:))
        return @"setScrollIndicatorStyle";
    else if (selector == @selector(setViewportWidth:))
        return @"setViewportWidth";
    else if (selector == @selector(statfs:))
        return @"statfs";
    else if (selector == @selector(supports:))
        return @"supports";
    else if (selector == @selector(unload))
        return @"unload";
    else
        return nil;
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector {
    return [self webScriptNameForSelector:selector] == nil;
}

- (void) addInternalRedirect:(NSString *)from :(NSString *)to {
    [CyteWebViewController performSelectorOnMainThread:@selector(addDiversion:) withObject:[[[Diversion alloc] initWithFrom:from to:to] autorelease] waitUntilDone:NO];
}

- (void) close {
    [indirect_ performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
}

- (NSString *) getKernelString:(NSString *)name {
    const char *string([name UTF8String]);

    size_t size;
    if (sysctlbyname(string, NULL, &size, NULL, 0) == -1)
        return (id) [NSNull null];

    char value[size + 1];
    if (sysctlbyname(string, value, &size, NULL, 0) == -1)
        return (id) [NSNull null];

    // XXX: just in case you request something ludicrous
    value[size] = '\0';

    return [NSString stringWithCString:value];
}

- (NSObject *) getIORegistryEntry:(NSString *)path :(NSString *)entry {
    NSObject *value(CYIOGetValue([path UTF8String], entry));

    if (value != nil)
        if ([value isKindOfClass:[NSData class]])
            value = CYHex((NSData *) value);

    return value;
}

- (NSString *) getLocaleIdentifier {
    _H<const __CFLocale> locale(CFLocaleCopyCurrent(), true);
    return locale == NULL ? (NSString *) [NSNull null] : (NSString *) CFLocaleGetIdentifier(locale);
}

- (NSArray *) getPreferredLanguages {
    return [NSLocale preferredLanguages];
}

- (NSNumber *) isReachable:(NSString *)name {
    return [NSNumber numberWithBool:CyteIsReachable([name UTF8String])];
}

- (NSString *) localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)table {
    if (reinterpret_cast<id>(value) == [WebUndefined undefined])
        value = nil;
    if (reinterpret_cast<id>(table) == [WebUndefined undefined])
        table = nil;
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:table];
}

- (void) popViewController:(NSNumber *)value {
    if (value == (id) [WebUndefined undefined])
        value = [NSNumber numberWithBool:YES];
    [indirect_ performSelectorOnMainThread:@selector(popViewControllerWithNumber:) withObject:value waitUntilDone:NO];
}

- (void) registerFrame:(DOMHTMLIFrameElement *)iframe {
    WebFrame *frame([iframe contentFrame]);
    [indirect_ registerFrame:frame];
}

- (void) removeButton {
    [indirect_ removeButton];
}

- (void) scrollToBottom:(NSNumber *)animated {
    [indirect_ performSelectorOnMainThread:@selector(scrollToBottomAnimated:) withObject:animated waitUntilDone:NO];
}

- (void) setAllowsNavigationAction:(NSString *)value {
    [indirect_ performSelectorOnMainThread:@selector(setAllowsNavigationActionByNumber:) withObject:value waitUntilDone:NO];
}

- (void) setBadgeValue:(id)value {
    [indirect_ performSelectorOnMainThread:@selector(setBadgeValue:) withObject:value waitUntilDone:NO];
}

- (void) setButtonImage:(NSString *)button withStyle:(NSString *)style toFunction:(id)function {
    [indirect_ setButtonImage:button withStyle:style toFunction:function];
}

- (void) setButtonTitle:(NSString *)button withStyle:(NSString *)style toFunction:(id)function {
    [indirect_ setButtonTitle:button withStyle:style toFunction:function];
}

- (void) setHidesBackButton:(NSString *)value {
    [indirect_ performSelectorOnMainThread:@selector(setHidesBackButtonByNumber:) withObject:value waitUntilDone:NO];
}

- (void) setHidesNavigationBar:(NSString *)value {
    [indirect_ performSelectorOnMainThread:@selector(setHidesNavigationBarByNumber:) withObject:value waitUntilDone:NO];
}

- (void) setNavigationBarStyle:(NSString *)value {
    [indirect_ performSelectorOnMainThread:@selector(setNavigationBarStyle:) withObject:value waitUntilDone:NO];
}

- (void) setNavigationBarTintRed:(NSNumber *)red green:(NSNumber *)green blue:(NSNumber *)blue alpha:(NSNumber *)alpha {
    float opacity(alpha == (id) [WebUndefined undefined] ? 1 : [alpha floatValue]);
    UIColor *color([UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:opacity]);
    [indirect_ performSelectorOnMainThread:@selector(setNavigationBarTintColor:) withObject:color waitUntilDone:NO];
}

- (void) setPasteboardString:(NSString *)value {
    [[objc_getClass("UIPasteboard") generalPasteboard] setString:value];
}

- (void) setPasteboardURL:(NSString *)value {
    [[objc_getClass("UIPasteboard") generalPasteboard] setURL:[NSURL URLWithString:value]];
}

- (void) setScrollAlwaysBounceVertical:(NSNumber *)value {
    [indirect_ performSelectorOnMainThread:@selector(setScrollAlwaysBounceVerticalNumber:) withObject:value waitUntilDone:NO];
}

- (void) setScrollIndicatorStyle:(NSString *)style {
    [indirect_ performSelectorOnMainThread:@selector(setScrollIndicatorStyleWithName:) withObject:style waitUntilDone:NO];
}

- (void) setViewportWidth:(float)width {
    [indirect_ setViewportWidthOnMainThread:width];
}

- (NSArray *) statfs:(NSString *)path {
    struct statfs stat;

    if (path == nil || statfs([path UTF8String], &stat) == -1)
        return nil;

    return [NSArray arrayWithObjects:
        [NSNumber numberWithUnsignedLong:stat.f_bsize],
        [NSNumber numberWithUnsignedLong:stat.f_blocks],
        [NSNumber numberWithUnsignedLong:stat.f_bfree],
    nil];
}

- (NSString *) stringWithFormat:(NSString *)format arguments:(WebScriptObject *)arguments {
    //NSLog(@"SWF:\"%@\" A:%@", format, [arguments description]);
    unsigned count([arguments count]);
    id values[count];
    for (unsigned i(0); i != count; ++i)
        values[i] = [arguments objectAtIndex:i];
    return [[[NSString alloc] initWithFormat:format arguments:reinterpret_cast<va_list>(values)] autorelease];
}

- (BOOL) supports:(NSString *)feature {
    return [feature isEqualToString:@"window.open"];
}

- (void) unload {
    [[indirect_ rootViewController] performSelectorOnMainThread:@selector(unloadData) withObject:nil waitUntilDone:NO];
}

@end
