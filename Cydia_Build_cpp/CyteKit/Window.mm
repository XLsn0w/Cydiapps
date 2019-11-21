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

#include "CyteKit/ViewController.h"
#include "CyteKit/Window.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

@implementation CyteWindow {
    _transient UIViewController *root_;
}

- (void) setRootViewController:(UIViewController *)controller {
    if ([super respondsToSelector:@selector(setRootViewController:)])
        [super setRootViewController:controller];
    else {
        [self addSubview:[controller view]];
        [[root_ view] removeFromSuperview];
    }

    root_ = controller;
}

- (void) unloadData {
    [root_ unloadData];
}

@end
