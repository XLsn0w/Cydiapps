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

#ifndef CyteKit_URLProtocol_H
#define CyteKit_URLProtocol_H

#include <UIKit/UIKit.h>

@interface CyteURLProtocol : NSURLProtocol

+ (NSString *) scheme;

- (void) _returnPNGWithImage:(UIImage *)icon forRequest:(NSURLRequest *)request;
- (bool) loadForPath:(NSString *)path ofRequest:(NSURLRequest *)request;

@end

#endif//CyteKit_URLProtocol_H
