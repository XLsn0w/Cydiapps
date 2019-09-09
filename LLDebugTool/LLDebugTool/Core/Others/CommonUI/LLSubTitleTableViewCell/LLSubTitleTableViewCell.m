//
//  LLSubTitleTableViewCell.m
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

#import "LLSubTitleTableViewCell.h"
#import "LLConfig.h"
#import "LLMacros.h"
#import "LLThemeManager.h"

@interface LLSubTitleTableViewCell ()

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTextViewMaxHeightConstraint;

@end

@implementation LLSubTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)dealloc {
    [self.contentView removeObserver:self forKeyPath:@"frame" context:nil];
}

- (void)setContentText:(NSString *)contentText {
    if (![_contentText isEqualToString:contentText]) {
        _contentText = [contentText copy];
        self.contentTextView.scrollEnabled = NO;
        self.contentTextView.text = _contentText;
    }
}

#pragma mark - Primary
- (void)initial {
    self.contentTextViewMaxHeightConstraint.constant = (NSInteger)(LL_SCREEN_HEIGHT * 0.7);
    [self.contentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    // You must set UITextView selectable to YES under ios 8, otherwise, you can't set textColor.
    // See https://stackoverflow.com/questions/21221281/ios-7-cant-set-font-color-of-uitextview-in-custom-uitableview-cell
    self.contentTextView.selectable = YES;
    self.contentTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.contentTextView.backgroundColor = nil;
    self.contentTextView.textColor = [LLThemeManager shared].primaryColor;
    self.contentTextView.selectable = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentLabelTapAction:)];
    [self.contentTextView addGestureRecognizer:tap];
}

- (void)contentLabelTapAction:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(LLSubTitleTableViewCell:didSelectedContentView:)]) {
        [self.delegate LLSubTitleTableViewCell:self didSelectedContentView:self.contentTextView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.contentView && [keyPath isEqualToString:@"frame"]) {
        CGRect rect = [change[NSKeyValueChangeNewKey] CGRectValue];
        // See LLSubTitleTableViewCell.xib
        // Subtraction 1 to avoid bug.
        if (rect.size.height >= 10 + 25 + 5 + self.contentTextViewMaxHeightConstraint.constant + 5 - 1) {
            self.contentTextView.scrollEnabled = YES;
        } else {
            self.contentTextView.scrollEnabled = NO;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
