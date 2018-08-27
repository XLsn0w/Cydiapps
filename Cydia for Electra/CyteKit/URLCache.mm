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

#include "CyteKit/URLCache.h"
#include "Substrate.hpp"

#include <Menes/ObjectHandle.h>

static _H<NSMutableSet> CachedURLs_([NSMutableSet setWithCapacity:32]);

@implementation CyteURLCache {
}

- (void) logEvent:(NSString *)event forRequest:(NSURLRequest *)request {
#if !ForRelease
    if (false);
    else if ([event isEqualToString:@"no-cache"])
        event = @"!!!";
    else if ([event isEqualToString:@"store"])
        event = @">>>";
    else if ([event isEqualToString:@"invalid"])
        event = @"???";
    else if ([event isEqualToString:@"memory"])
        event = @"mem";
    else if ([event isEqualToString:@"disk"])
        event = @"ssd";
    else if ([event isEqualToString:@"miss"])
        event = @"---";

    NSLog(@"%@: %@", event, [[request URL] absoluteString]);
#endif
}

- (void) storeCachedResponse:(NSCachedURLResponse *)cached forRequest:(NSURLRequest *)request {
    if (NSURLResponse *response = [cached response])
        if (NSString *mime = [response MIMEType])
            if ([mime isEqualToString:@"text/cache-manifest"]) {
                NSURL *url([response URL]);

#if !ForRelease
                NSLog(@"###: %@", [url absoluteString]);
#endif

                @synchronized (CachedURLs_) {
                    [CachedURLs_ addObject:url];
                }
            }

    [super storeCachedResponse:cached forRequest:request];
}

- (void) createDiskCachePath {
    [super createDiskCachePath];
}

@end

MSClassHook(NSURLConnection)

MSHook(id, NSURLConnection$init$, NSURLConnection *self, SEL _cmd, NSURLRequest *request, id delegate, BOOL usesCache, int64_t maxContentLength, BOOL startImmediately, NSDictionary *connectionProperties) {
    NSMutableURLRequest *copy([[request mutableCopy] autorelease]);

    NSURL *url([copy URL]);

    @synchronized (CachedURLs_) {
        if (NSString *control = [copy valueForHTTPHeaderField:@"Cache-Control"])
            if ([control isEqualToString:@"max-age=0"])
                if ([CachedURLs_ containsObject:url]) {
#if !ForRelease
                    NSLog(@"~~~: %@", url);
#endif

                    [copy setCachePolicy:NSURLRequestReturnCacheDataDontLoad];

                    [copy setValue:nil forHTTPHeaderField:@"Cache-Control"];
                    [copy setValue:nil forHTTPHeaderField:@"If-Modified-Since"];
                    [copy setValue:nil forHTTPHeaderField:@"If-None-Match"];
                }
    }

    if ((self = _NSURLConnection$init$(self, _cmd, copy, delegate, usesCache, maxContentLength, startImmediately, connectionProperties)) != nil) {
    } return self;
}

CYHook(NSURLConnection, init$, _initWithRequest:delegate:usesCache:maxContentLength:startImmediately:connectionProperties:)
