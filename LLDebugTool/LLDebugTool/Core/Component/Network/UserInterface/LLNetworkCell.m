//
//  LLNetworkCell.m
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

#import "LLNetworkCell.h"
#import "LLConfig.h"

@interface LLNetworkCell ()

@property (weak, nonatomic) IBOutlet UILabel *hostLabel;

@property (weak, nonatomic) IBOutlet UILabel *paramLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) LLNetworkModel *model;

@end

@implementation LLNetworkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithModel:(LLNetworkModel *)model {
    if (_model != model) {
        _model = model;
        self.hostLabel.text = _model.url.host;
        self.paramLabel.text = _model.url.path;
        self.dateLabel.text = [_model.startDate substringFromIndex:11];
    }
}

#pragma mark - Primary
- (void)initial {
    self.hostLabel.font = [UIFont boldSystemFontOfSize:19];
    self.hostLabel.adjustsFontSizeToFitWidth = YES;
}

@end
