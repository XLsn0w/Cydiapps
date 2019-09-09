//
//  LLLogCell.m
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

#import "LLLogCell.h"
#import "LLConfig.h"

@interface LLLogCell ()

@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *funcLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) LLLogModel *model;

@end

@implementation LLLogCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithModel:(LLLogModel *)model {
    _model = model;
    if (model.file.length) {
        _fileLabel.attributedText = [self title:@"File : " content:model.file];
    } else {
        _fileLabel.attributedText = nil;
    }
    if (model.function.length) {
        _funcLabel.attributedText = [self title:@"Func : " content:model.function];
    } else {
        _funcLabel.attributedText = nil;
    }
    if (model.date.length) {
        _dateLabel.attributedText = [self title:@"Date : " content:model.date];
    } else {
        _dateLabel.attributedText = nil;
    }
    _messageLabel.text = model.message ?: @"None Message";
}

#pragma mark - Primary
- (void)initial {
    self.messageLabel.font = [UIFont boldSystemFontOfSize:18];
    _fileLabel.text = nil;
    _funcLabel.text = nil;
    _dateLabel.text = nil;
    _messageLabel.text = nil;
}

- (NSAttributedString *)title:(NSString *)title content:(NSString *)content {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
    [attr appendAttributedString:[[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}]];
    return attr;
}
@end
