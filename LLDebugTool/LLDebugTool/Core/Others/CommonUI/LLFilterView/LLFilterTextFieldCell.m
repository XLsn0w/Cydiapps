//
//  LLFilterTextFieldCell.m
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

#import "LLFilterTextFieldCell.h"
#import "LLNoneCopyTextField.h"
#import "LLFilterFilePickerView.h"
#import "LLFilterDatePickerView.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLFactory.h"
#import "LLThemeManager.h"

@interface LLFilterTextFieldCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelWidthConstraint;

@property (weak, nonatomic) IBOutlet LLNoneCopyTextField *textField;

@property (strong, nonatomic) LLFilterTextFieldModel *model;

@property (strong, nonatomic) LLFilterFilePickerView *pickerView;

@property (strong, nonatomic) LLFilterDatePickerView *datePicker;

@property (strong, nonatomic) UIView *accessoryView;

@end

@implementation LLFilterTextFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)confirmWithModel:(LLFilterTextFieldModel *)model {
    if (_model != model) {
        _model = model;
        _titleLabel.text = model.title;
        if (model.autoAdjustWidthToTitle) {
            [_titleLabel sizeToFit];
            _titleLabelWidthConstraint.constant = _titleLabel.frame.size.width + 4;
        } else {
            _titleLabelWidthConstraint.constant = model.titleWidth ?: 60;
        }
        _textField.text = model.currentFilter;
        _accessoryView = nil;
        _pickerView = nil;
        _datePicker = nil;
        self.textField.inputAccessoryView = self.accessoryView;
        if (model.useDatePicker) {
            self.textField.inputView = self.datePicker;
        } else {
            self.textField.inputView = self.pickerView;
        }
    }
    if (_model == nil || (_model.filters.count == 0 && !_model.useDatePicker)) {
        self.textField.enabled = NO;
    } else {
        self.textField.enabled = YES;
    }
}

- (void)cancelButtonClick:(UIButton *)sender {
    [self.textField resignFirstResponder];
}

- (void)confirmButtonClick:(UIButton *)sender {
    [self.textField resignFirstResponder];
    if (self.model.useDatePicker) {
        NSString *filter = [self.datePicker currentDateString];
        self.model.currentFilter = filter;
        self.textField.text = filter;
    } else {
        NSInteger row = [self.pickerView selectedRowInComponent:0];
        NSString *filter = nil;
        if (row > 0) {
            filter = self.model.filters[row - 1];
        }
        self.model.currentFilter = filter;
        self.textField.text = filter;
    }
    if (_confirmBlock) {
        _confirmBlock();
    }
}

#pragma mark - Primary
- (void)initial {
    _textField.placeholder = @"Please Select";
    _titleLabel.textColor = [LLThemeManager shared].primaryColor;
}

#pragma mark - Lazy load
- (LLFilterFilePickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[LLFilterFilePickerView alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 220) model:self.model];
    }
    return _pickerView;
}

- (LLFilterDatePickerView *)datePicker {
    if (!_datePicker) {
        _datePicker = [[LLFilterDatePickerView alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 220) fromDate:_model.fromDate endDate:_model.endDate];
    }
    return _datePicker;
}

- (UIView *)accessoryView {
    if (!_accessoryView) {
        _accessoryView = [LLFactory getView:nil frame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 40) backgroundColor:[UIColor whiteColor]];
        UIButton *cancel = [LLFactory getButton:_accessoryView frame:CGRectMake(12, 0, 60, _accessoryView.frame.size.height) target:self action:@selector(cancelButtonClick:)];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        cancel.titleLabel.font = [UIFont systemFontOfSize:15];
        
        UIButton *confirm = [LLFactory getButton:_accessoryView frame:CGRectMake(_accessoryView.frame.size.width - 60 - 12, 0, 60, _accessoryView.frame.size.height) target:self action:@selector(confirmButtonClick:)];
        [confirm setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        confirm.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [LLFactory lineView:CGRectMake(0, 0, _accessoryView.frame.size.width, 1) superView:_accessoryView];
    }
    return _accessoryView;
}


@end
