//
//  LLSandboxCell.m
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

#import "LLSandboxCell.h"
#import "LLFormatterTool.h"
#import "LLConfig.h"
#import "LLImageNameConfig.h"
#import "LLThemeManager.h"

@interface LLSandboxCell ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@property (strong, nonatomic) LLSandboxModel *model;

@end

@implementation LLSandboxCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithModel:(LLSandboxModel *)model {
    _model = model;
    self.titleLabel.text = model.name;
    self.contentLabel.text = [NSString stringWithFormat:@"%@", [[LLFormatterTool shared] stringFromDate:model.modifiDate style:FormatterToolDateStyle1]];
    self.sizeLabel.text = [NSString stringWithFormat:@"%@",model.totalFileSizeString];
    if (model.isDirectory && model.subModels.count) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    if (model.isHidden) {
        self.contentView.alpha = 0.6;
    } else {
        self.contentView.alpha = 1.0;
    }
    if ([model.iconName isEqualToString:kFolderImageName] || [model.iconName isEqualToString:kEmptyFolderImageName]) {
        self.icon.image = [[UIImage LL_imageNamed:model.iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.icon.image = [UIImage LL_imageNamed:model.iconName];
    }
}

#pragma mark - Primary
- (void)initial {
    self.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    self.icon.tintColor = [LLThemeManager shared].primaryColor;
    
    UILongPressGestureRecognizer *longPG = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
    [self.contentView addGestureRecognizer:longPG];
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(LL_tableViewCellDidLongPress:)]) {
            [_delegate LL_tableViewCellDidLongPress:self];
        }
    }
}

@end
