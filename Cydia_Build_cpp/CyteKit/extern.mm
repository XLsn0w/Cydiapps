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

#include <CyteKit/UCPlatform.h>

#include <CyteKit/RegEx.hpp>
#include <CyteKit/WebViewController.h>
#include <CyteKit/extern.h>

#include <SystemConfiguration/SystemConfiguration.h>
#include <UIKit/UIKit.h>

#include <sys/sysctl.h>

#include <Menes/ObjectHandle.h>

bool IsWildcat_;
CGFloat ScreenScale_;

char *Machine_;
const char *System_;

bool CyteIsReachable(const char *name) {
    SCNetworkReachabilityFlags flags; {
        SCNetworkReachabilityRef reachability(SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, name));
        SCNetworkReachabilityGetFlags(reachability, &flags);
        CFRelease(reachability);
    }

    // XXX: this elaborate mess is what Apple is using to determine this? :(
    // XXX: do we care if the user has to intervene? maybe that's ok?
    return
        (flags & kSCNetworkReachabilityFlagsReachable) != 0 && (
            (flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0 || (
                (flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0 ||
                (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0
            ) && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0 ||
            (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0
        )
    ;
}

void CyteInitialize(NSString *agent) {
    UIScreen *screen([UIScreen mainScreen]);
    if ([screen respondsToSelector:@selector(scale)])
        ScreenScale_ = [screen scale];
    else
        ScreenScale_ = 1;

    UIDevice *device([UIDevice currentDevice]);
    if ([device respondsToSelector:@selector(userInterfaceIdiom)]) {
        UIUserInterfaceIdiom idiom([device userInterfaceIdiom]);
        if (idiom == UIUserInterfaceIdiomPad)
            IsWildcat_ = true;
    }

    size_t size;

    sysctlbyname("kern.osversion", NULL, &size, NULL, 0);
    char *osversion = new char[size];
    if (sysctlbyname("kern.osversion", osversion, &size, NULL, 0) == -1)
        perror("sysctlbyname(\"kern.osversion\", ?)");
    else
        System_ = osversion;

    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = new char[size];
    if (sysctlbyname("hw.machine", machine, &size, NULL, 0) == -1)
        perror("sysctlbyname(\"hw.machine\", ?)");
    else
        Machine_ = machine;

    _H<NSString> product;
    _H<NSString> safari;

    if (NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:@"/Applications/MobileSafari.app/Info.plist"]) {
        product = [info objectForKey:@"SafariProductVersion"] ?: [info objectForKey:@"CFBundleShortVersionString"];
        safari = [info objectForKey:@"CFBundleVersion"];
    }

    agent = [NSString stringWithFormat:@"%@ CyF/%.2f", agent, kCFCoreFoundationVersionNumber];

    if (safari != nil)
        if (RegEx match = RegEx("([0-9]+(\\.[0-9]+)+).*", safari))
            agent = [NSString stringWithFormat:@"Safari/%@ %@", match[1], agent];
    if (RegEx match = RegEx("([0-9]+[A-Z][0-9]+[a-z]?).*", System_))
        agent = [NSString stringWithFormat:@"Mobile/%@ %@", match[1], agent];
    if (product != nil)
        if (RegEx match = RegEx("([0-9]+(\\.[0-9]+)+).*", product))
            agent = [NSString stringWithFormat:@"Version/%@ %@", match[1], agent];

    [CyteWebViewController setApplicationNameForUserAgent:agent];
}
