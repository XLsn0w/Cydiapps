//
//  LLFilterLabelCell.m
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

#import "LLFilterLabelCell.h"
#import "LLConfig.h"
#import "LLThemeManager.h"

@interface LLFilterLabelCell ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, strong) LLFilterLabelModel *model;

@end

@implementation LLFilterLabelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithModel:(LLFilterLabelModel *)model {
    _model = model;
    _label.text = model.message;
    if (_model.isSelected) {
        _label.textColor = [LLThemeManager shared].backgroundColor;
        _bgView.backgroundColor = [LLThemeManager shared].primaryColor;
    } else {
        _label.textColor = [LLThemeManager shared].primaryColor;
        _bgView.backgroundColor = [LLThemeManager shared].backgroundColor;
    }
}

#pragma mark - Primary
- (void)initial {
    // Fix iPhone SE show incomplete problems.
    _label.font = [UIFont systemFontOfSize:15];
    
    _bgView.layer.cornerRadius = 5;
    _bgView.layer.borderWidth = 0.5;
    _bgView.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;
    _bgView.layer.masksToBounds = YES;
}

@end
