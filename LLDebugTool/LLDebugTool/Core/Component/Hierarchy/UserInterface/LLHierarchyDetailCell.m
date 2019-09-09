//
//  LLHierarchyDetailCell.m
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

#import "LLHierarchyDetailCell.h"
#import "UIView+LL_Utils.h"

@implementation LLHierarchyDetailSectionModel

- (instancetype)initWithTitle:(NSString *)title models:(NSArray<LLHierarchyDetailModel *> *)models {
    if (self = [super init]) {
        _title = title;
        _models = [models copy];
    }
    return self;
}

@end

@implementation LLHierarchyDetailModel

- (instancetype)initWithTitle:(NSString *_Nullable)title content:(NSString *_Nullable)content {
    if (self = [super init]) {
        _title = title;
        _content = content;
    }
    return self;
}

@end

@interface LLHierarchyDetailCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeightConstraint;

@end

@implementation LLHierarchyDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
    // Initialization code
}

- (void)setModel:(LLHierarchyDetailModel *)model {
    if (_model != model) {
        _model = model;
    }
}

#pragma mark - Primary
- (void)initial {
    
}

- (void)updateUI:(LLHierarchyDetailModel *)model {
    self.titleLabel.text = model.title;
    self.contentLabel.text = model.content;
    [self.contentLabel sizeToFit];
    self.contentLabelHeightConstraint.constant = self.contentLabel.LL_height;
}

@end
