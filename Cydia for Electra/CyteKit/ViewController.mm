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

#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#include "CyteKit/ViewController.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

@implementation UIViewController (Cydia)

- (BOOL) hasLoaded {
    return YES;
}

- (void) reloadData {
    [self view];
}

- (void) unloadData {
    if (UIViewController *modal = [self modalViewController])
        [modal unloadData];
}

- (UIViewController *) parentOrPresentingViewController {
    if (UIViewController *parent = [self parentViewController])
        return parent;
    if ([self respondsToSelector:@selector(presentingViewController)])
        return [self presentingViewController];
    return nil;
}

- (UIViewController *) rootViewController {
    UIViewController *base(self);
    while ([base parentOrPresentingViewController] != nil)
        base = [base parentOrPresentingViewController];
    return base;
}

- (NSURL *) navigationURL {
    return nil;
}

@end

@implementation CyteViewController {
    _transient id delegate_;
    BOOL loaded_;
    _H<UIColor> color_;
}

- (void) setDelegate:(id)delegate {
    delegate_ = delegate;
}

- (id) delegate {
    return delegate_;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Load on first appearance. We don't need to set the loaded flag here
    // because it is set for us the first time -reloadData is called.
    if (![self hasLoaded])
        [self reloadData];
}

- (BOOL) hasLoaded {
    return loaded_;
}

- (void) releaseSubviews {
    loaded_ = NO;
}

- (void) setView:(UIView *)view {
    // Nasty hack for 2.x-compatibility. In 3.0+, we can and
    // should just override -viewDidUnload instead.
    if (view == nil)
        [self releaseSubviews];

    [super setView:view];
}

- (void) reloadData {
    [super reloadData];

    // This is called automatically on the first appearance of a controller,
    // or any other time it needs to reload the information shown. However (!),
    // this is not called by any tab bar or navigation controller's -reloadData
    // method unless this controller returns YES from -hadLoaded.
    loaded_ = YES;
}

- (void) unloadData {
    loaded_ = NO;
    [super unloadData];
}

- (void) setPageColor:(UIColor *)color {
    if (color == nil)
        color = [UIColor groupTableViewBackgroundColor];
    color_ = color;
}

- (UIColor *) pageColor {
    return color_;
}

#include "InterfaceOrientation.h"

@end
