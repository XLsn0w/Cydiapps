//
//  LLFilterDatePickerView.m
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

#import "LLFilterDatePickerView.h"
#import "LLMacros.h"
#import "LLFactory.h"
#import "LLFormatterTool.h"

@interface LLFilterDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@property (assign, nonatomic) BOOL isSelectAll;

@end

@implementation LLFilterDatePickerView

- (instancetype)initWithFrame:(CGRect)frame fromDate:(NSDate *)fromDate endDate:(NSDate *)endDate {
    if (self = [super initWithFrame:frame]) {
        if (!fromDate) {
            fromDate = [NSDate date];
        }
        if (!endDate) {
            endDate = [NSDate date];
        }
        
        self.delegate = self;
        self.dataSource = self;
        
        if ([endDate timeIntervalSinceDate:fromDate] >= 0) {
            NSMutableArray *days = [[NSMutableArray alloc] init];
            NSDate *date = [fromDate copy];
            while ([endDate timeIntervalSinceDate:date] >= 0) {
                NSString *dateString = [[LLFormatterTool shared] stringFromDate:date style:FormatterToolDateStyle2];
                if (dateString.length) {
                    [days addObject:dateString];
                }
                date = [date dateByAddingTimeInterval:60 * 60 * 24];
            }
            
            NSMutableArray *hours = [[NSMutableArray alloc] init];
            for (int i = 0; i < 24; i++) {
                [hours addObject:[NSString stringWithFormat:@"%02d",i]];
            }
            NSMutableArray *minutes = [[NSMutableArray alloc] init];
            NSMutableArray *seconds = [[NSMutableArray alloc] init];
            for (int i = 0; i < 60; i++) {
                [minutes addObject:[NSString stringWithFormat:@"%02d",i]];
                [seconds addObject:[NSString stringWithFormat:@"%02d",i]];
            }
            self.dataArray = @[days,hours,minutes,seconds];
            
            [self selectRow:1 inComponent:0 animated:NO];
        }
    }
    return self;
}

- (NSString *)currentDateString {
    NSInteger dayRow = [self selectedRowInComponent:0];
    if (dayRow > 0) {
        NSString *day = self.dataArray[0][dayRow - 1];
        NSString *hour = self.dataArray[1][[self selectedRowInComponent:1]];
        NSString *min = self.dataArray[2][[self selectedRowInComponent:2]];
        NSString *sec = self.dataArray[3][[self selectedRowInComponent:3]];
        return [NSString stringWithFormat:@"%@ %@:%@:%@",day,hour,min,sec];
    }
    return nil;
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.isSelectAll) {
        return 1;
    }
    return self.dataArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.dataArray[component] count] + 1;
    }
    return [self.dataArray[component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        if (row == 0) {
            return @"All";
        }
        return self.dataArray[component][row - 1];
    }
    NSString *title = self.dataArray[component][row];
    if (component == 1) {
        title = [title stringByAppendingString:@" h"];
    } else if (component == 2) {
        title = [title stringByAppendingString:@" m"];
    } else if (component == 3) {
        title = [title stringByAppendingString:@" s"];
    }
    return title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [LLFactory getLabel:nil frame:CGRectZero text:nil font:18 textColor:nil];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.isSelectAll) {
        return LL_SCREEN_WIDTH;
    }
    if (component == 0) {
        return 150;
    }
    return (LL_SCREEN_WIDTH - 200) / (self.dataArray.count - 1);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if (self.isSelectAll != (row == 0)) {
            self.isSelectAll = (row == 0);
            [self reloadAllComponents];
        }
    }
}

@end
