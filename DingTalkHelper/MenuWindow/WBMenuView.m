//
//  WBMenuView.m
//  FlowWindow
//
//  Created by buginux on 2017/7/27.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBMenuView.h"

@implementation WBMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setTitle:@"菜单" forState:UIControlStateNormal];
    [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    menuButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [menuButton sizeToFit];
    [self addSubview:menuButton];
    self.menuButton = menuButton;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    [self addSubview:closeButton];
    self.closeButton = closeButton;
    
    CGSize menuButtonSize = menuButton.frame.size;
    CGSize closeButtonSize = closeButton.frame.size;
    menuButton.frame = CGRectMake(8.0, 0.0, menuButtonSize.width, menuButtonSize.height);
    closeButton.frame = CGRectMake(CGRectGetMaxX(menuButton.frame) + 8.0, CGRectGetMinY(menuButton.frame), closeButtonSize.width, closeButtonSize.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = CGRectGetMaxX(self.closeButton.frame) + 8.0;
    CGFloat height = CGRectGetHeight(self.menuButton.frame);
    return CGSizeMake(width, height);
}


@end
