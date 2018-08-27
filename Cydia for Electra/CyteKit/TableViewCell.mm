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

#include "CyteKit/TableViewCell.h"

#include "iPhonePrivate.h"
#include <Menes/ObjectHandle.h>

@implementation CyteTableViewCellContentView {
    _transient id<CyteTableViewCellDelegate> delegate_;
}

- (id) initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame]) != nil) {
        [self setNeedsDisplayOnBoundsChange:YES];
    } return self;
}

- (id) delegate {
    return delegate_;
}

- (void) setDelegate:(id<CyteTableViewCellDelegate>)delegate {
    delegate_ = delegate;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    [delegate_ drawContentRect:rect];
}

@end

@implementation CyteTableViewCell {
    _H<CyteTableViewCellContentView, 1> content_;
    bool highlighted_;
}

- (instancetype) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) != nil) {
        UIView *content([self contentView]);
        CGRect bounds([content bounds]);

        self.content = [[[CyteTableViewCellContentView alloc] initWithFrame:bounds] autorelease];
        [self.content setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [content addSubview:self.content];

        [self.content setDelegate:(id<CyteTableViewCellDelegate>)self];
    } return self;
}

- (void) _updateHighlightColorsForView:(UIView *)view highlighted:(BOOL)highlighted {
    if (view == (UIView *) content_)
        highlighted_ = highlighted;

    [super _updateHighlightColorsForView:view highlighted:highlighted];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated {
    highlighted_ = selected;

    [super setSelected:selected animated:animated];
    [content_ setNeedsDisplay];
}

- (void) setContent:(CyteTableViewCellContentView *)content {
    content_ = content;
}

- (CyteTableViewCellContentView *) content {
    return content_;
}

- (bool) highlighted {
    return highlighted_;
}

@end
