//
//  LLEntryRectView.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLEntryRectView.h"
#import "LLThemeManager.h"
#import "LLConfig.h"
#import "LLFactory.h"
#import "LLImageNameConfig.h"
#import "UIView+LL_Utils.h"
#import "LLMacros.h"

@interface LLEntryRectView ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UILabel *specialScreenLabel;

@end

@implementation LLEntryRectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Primary
- (void)initial {
    self.backgroundColor = [LLThemeManager shared].backgroundColor;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;

    if (LL_IS_SPECIAL_SCREEN) {
        self.specialScreenLabel = [LLFactory getLabel:self frame:CGRectMake(5, 0, 100, self.LL_height) text:@"Debug" font:16 textColor:[LLThemeManager shared].primaryColor];
        [self.specialScreenLabel sizeToFit];
        self.specialScreenLabel.LL_height = self.LL_height;
        self.LL_width = self.specialScreenLabel.LL_right + 5;
    } else {
        self.icon = [LLFactory getImageView:self frame:CGRectMake(5, (self.LL_height - 14) / 2.0, 14, 14) image:[UIImage LL_imageNamed:kLogoImageName color:[LLThemeManager shared].primaryColor]];
        self.label = [LLFactory getLabel:self frame:CGRectMake(self.icon.LL_right + 5, 0, 100, self.LL_height) text:@"LLDebugTool" font:12 textColor:[LLThemeManager shared].primaryColor];
        [self.label sizeToFit];
        self.label.LL_height = self.LL_height;
        self.LL_width = self.label.LL_right + 5;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeManagerUpdatePrimaryColorNotificaion:) name:kThemeManagerUpdatePrimaryColorNotificaionName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeManagerUpdateBackgroundColorNotificaion:) name:kThemeManagerUpdateBackgroundColorNotificaionName object:nil];
}

#pragma mark - NSNotification
- (void)didReceiveThemeManagerUpdatePrimaryColorNotificaion:(NSNotification *)notification {
    self.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;
    self.icon.image = [UIImage LL_imageNamed:kLogoImageName color:[LLThemeManager shared].primaryColor];
    self.label.textColor = [LLThemeManager shared].primaryColor;
    self.specialScreenLabel.textColor = [LLThemeManager shared].primaryColor;
}

- (void)didReceiveThemeManagerUpdateBackgroundColorNotificaion:(NSNotification *)notification {
    self.backgroundColor = [LLThemeManager shared].backgroundColor;
}


@end
