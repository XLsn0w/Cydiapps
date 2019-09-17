//
//  RoundedViews.m
//  rootlessJB
//
//  Created by Joseph Shenton on 6/2/19.
//  Copyright © 2019 Jake James. All rights reserved.
//

#import "RoundedViews.h"

@implementation RoundView
- (void)setCornerRadius:(CGFloat *)cornerRadius {
    [self updateCornerRadius];
}

- (void)updateCornerRadius {
    self.layer.cornerRadius = *(self.cornerRadius);
//    self.layer.masksToBounds = self.rounded ? true : false;
}
@end

@implementation RoundImageView
- (void)setCornerRadius:(CGFloat *)cornerRadius {
    [self updateCornerRadius];
}

- (void)updateCornerRadius {
    self.layer.cornerRadius = *(self.cornerRadius);
    //    self.layer.masksToBounds = self.rounded ? true : false;
}
@end

@implementation RoundVisualEffectView

- (void)setCornerRadius:(CGFloat *)cornerRadius {
    [self updateCornerRadius];
}

- (void)updateCornerRadius {
    self.layer.cornerRadius = *(self.cornerRadius);
    //    self.layer.masksToBounds = self.rounded ? true : false;
}
@end

@implementation RoundButton
- (void)setCornerRadius:(CGFloat *)cornerRadius {
    [self updateCornerRadius];
}

- (void)updateCornerRadius {
    self.layer.cornerRadius = *(self.cornerRadius);
    //    self.layer.masksToBounds = self.rounded ? true : false;
}
@end
