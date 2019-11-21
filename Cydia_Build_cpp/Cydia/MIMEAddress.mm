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

#include "Cydia/MIMEAddress.h"
#include "CyteKit/RegEx.hpp"

#include "iPhonePrivate.h"

@implementation MIMEAddress

- (NSString *) name {
    return name_;
}

- (NSString *) address {
    return address_;
}

- (void) setAddress:(NSString *)address {
    address_ = address;
}

+ (MIMEAddress *) addressWithString:(NSString *)string {
    return [[[MIMEAddress alloc] initWithString:string] autorelease];
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"address",
        @"name",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (id) initWithString:(NSString *)string {
    if ((self = [super init]) != nil) {
        const char *data = [string UTF8String];
        size_t size = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

        static RegEx address_r("\"?(.*)\"? <([^>]*)>");

        if (address_r(data, size)) {
            name_ = address_r[1];
            address_ = address_r[2];
        } else {
            name_ = string;
            address_ = nil;
        }
    } return self;
}

@end
