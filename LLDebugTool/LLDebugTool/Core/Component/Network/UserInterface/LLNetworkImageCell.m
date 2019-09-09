//
//  LLNetworkImageCell.m
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

#import "LLNetworkImageCell.h"
#import "LLMacros.h"

@interface LLNetworkImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LLNetworkImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)setUpImage:(UIImage *)image {
    self.imgView.image = image;
    if (image) {
        CGSize size = image.size;
        CGFloat height = LL_SCREEN_WIDTH * size.height / size.width;
        if (height != self.imgViewHeightConstraint.constant) {
            self.imgViewHeightConstraint.constant = height;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }
    }
}

#pragma mark - Primary
- (void)initial {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
}

@end
