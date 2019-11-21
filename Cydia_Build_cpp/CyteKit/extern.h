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

#ifndef CyteKit_extern_H
#define CyteKit_extern_H

#include <CoreGraphics/CoreGraphics.h>
#include <Foundation/Foundation.h>

extern bool IsWildcat_;
extern CGFloat ScreenScale_;

extern char *Machine_;
extern const char *System_;

bool CyteIsReachable(const char *name);

void CyteInitialize(NSString *agent);

static inline double Retina(double value) {
    value *= ScreenScale_;
    value = round(value);
    value /= ScreenScale_;
    return value;
}

static inline CGRect Retina(CGRect value) {
    value.origin.x *= ScreenScale_;
    value.origin.y *= ScreenScale_;
    value.size.width *= ScreenScale_;
    value.size.height *= ScreenScale_;
    value = CGRectIntegral(value);
    value.origin.x /= ScreenScale_;
    value.origin.y /= ScreenScale_;
    value.size.width /= ScreenScale_;
    value.size.height /= ScreenScale_;
    return value;
}

#endif//CyteKit_extern_H
