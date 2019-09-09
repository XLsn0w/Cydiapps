//
//  LLNetworkFilterView.m
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

#import "LLNetworkFilterView.h"
#import "LLFilterEventView.h"
#import "LLFilterDateView.h"
#import "UIButton+LL_Utils.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLFormatterTool.h"
#import "LLNetworkModel.h"
#import "LLFactory.h"
#import "UIView+LL_Utils.h"
#import "LLThemeManager.h"
#import "LLConst.h"

@interface LLNetworkFilterView ()

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, assign) CGRect normalFrame;

// Buttons
@property (nonatomic, strong) UIView *btnsBgView;

@property (nonatomic, strong) NSMutableArray *filterBtns;

// Details
@property (nonatomic, strong) NSMutableArray *filterViews;

@property (nonatomic, strong) LLFilterEventView *hostView;

@property (nonatomic, strong) LLFilterEventView *typeView;

@property (nonatomic, strong) LLFilterDateView *dateView;

// Data
@property (nonatomic, strong) NSArray *currentHost;
@property (nonatomic, strong) NSArray *currentTypes;
@property (nonatomic, strong) NSDate *currentFromDate;
@property (nonatomic, strong) NSDate *currentEndDate;

@end

@implementation LLNetworkFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _normalFrame = frame;
        [self initial];
    }
    return self;
}

- (BOOL)isFiltering {
    BOOL ret = NO;
    for (UIButton *btn in self.filterBtns) {
        if (btn.isSelected) {
            ret = YES;
            break;
        }
    }
    return ret;
}

- (void)cancelFiltering {
    for (UIButton *btn in self.filterBtns) {
        if (btn.selected == YES) {
            [self filterButtonClick:btn];
        }
    }
}

- (void)configWithData:(NSArray <LLNetworkModel *>*)data {
  
    NSMutableSet *hostSet = [NSMutableSet set];
    
    NSString *fromString = data.lastObject.startDate;
    NSString *endString = data.firstObject.startDate;
    
    NSDate *fromDate = [[LLFormatterTool shared] dateFromString:fromString style:FormatterToolDateStyle1];
    NSDate *endDate = [[LLFormatterTool shared] dateFromString:endString style:FormatterToolDateStyle1];
    if (!fromDate) {
        fromDate = [NSDate date];
    }
    if (!endDate) {
        endDate = [NSDate date];
    }
    
    for (LLNetworkModel *model in data) {
        if (model.url.host.length) {
            [hostSet addObject:model.url.host];
        }
    }
    
    // Host Part
    [self.filterViews removeAllObjects];
    [self.filterViews addObject:self.hostView];
    self.hostView.hidden = YES;
    NSMutableArray *hostArray = [[NSMutableArray alloc] init];
    for (NSString *host in hostSet.allObjects) {
        LLFilterLabelModel *model = [[LLFilterLabelModel alloc] initWithMessage:host];
        [hostArray addObject:model];
    }
    CGFloat lineNo = (hostArray.count / self.hostView.averageCount + (hostArray.count % self.hostView.averageCount == 0 ? 0 : 1));
    if (lineNo > 6) {
        lineNo = 6;
    } else if (lineNo < 1) {
        lineNo = 1;
    }
    CGFloat eventHeight = lineNo * 40 + kLLGeneralMargin;
    self.hostView.frame = CGRectMake(self.hostView.frame.origin.x, self.hostView.frame.origin.y, self.hostView.frame.size.width, eventHeight);
    [self.hostView updateDataArray:hostArray];
    
    // Type Part
    [self.filterViews addObject:self.typeView];
    self.typeView.hidden = YES;
    
    // Date Part
    [self.filterViews addObject:self.dateView];
    self.dateView.hidden = YES;
    [self.dateView updateFromDate:fromDate endDate:endDate];
    
    // Final
    [self bringSubviewToFront:self.btnsBgView];
}

- (void)reCalculateFilters {
    if (_changeBlock) {
        _changeBlock(self.currentHost,self.currentTypes,
                     self.currentFromDate,self.currentEndDate);
    }
}

- (void)updateFilterButton:(UIView *)filterView count:(NSInteger)count {
    NSInteger index = [self.filterViews indexOfObject:filterView];
    if (index != NSNotFound) {
        UIButton *sender = self.filterBtns[index];
        NSString *title = self.titles[index];
        if (count == 0) {
            [sender setTitle:title forState:UIControlStateNormal];
        } else {
            [sender setTitle:[NSString stringWithFormat:@"%@ (%ld)",title,(long)count] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Action
- (void)filterButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == NO) {
        self.frame = self.normalFrame;
        [self hideDetailView:sender.tag];
    } else {
        for (UIButton *btn in self.filterBtns) {
            if (btn != sender && btn.selected) {
                btn.selected = NO;
                [self hideDetailView:btn.tag];
            }
        }
        [self showDetailView:sender.tag];
    }
    [self endEditing:YES];
}

#pragma mark - Primary
- (void)initial {
    self.filterViews = [[NSMutableArray alloc] init];
    self.filterBtns = [[NSMutableArray alloc] init];
    
    self.btnsBgView = [LLFactory getBackgroundView:self frame:self.bounds];
    
    CGFloat gap = 20;
    CGFloat itemHeight = 25;
    NSInteger count = self.titles.count;
    CGFloat itemWidth = (self.frame.size.width - gap * (count + 1)) / count;
    for (int i = 0; i < self.titles.count; i++) {
        UIButton *btn = [LLFactory getButton:self.btnsBgView frame:CGRectMake(i * (itemWidth + gap) + gap, (self.frame.size.height - itemHeight) / 2.0, itemWidth, itemHeight) target:self action:@selector(filterButtonClick:)];
        [btn setTitleColor:[LLThemeManager shared].primaryColor forState:UIControlStateNormal];
        [btn setTitleColor:[LLThemeManager shared].backgroundColor forState:UIControlStateSelected];
        [btn LL_setBackgroundColor:[LLThemeManager shared].backgroundColor forState:UIControlStateNormal];
        [btn LL_setBackgroundColor:[LLThemeManager shared].primaryColor forState:UIControlStateSelected];
        [btn setTitle:self.titles[i] forState:UIControlStateNormal];
        btn.tag = i;
        [btn LL_setCornerRadius:5];
        btn.layer.borderColor = [LLThemeManager shared].primaryColor.CGColor;
        btn.layer.borderWidth = 0.5;
        [self.filterBtns addObject:btn];
    }
    [LLFactory lineView:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1) superView:self.btnsBgView];
}

- (void)showDetailView:(NSInteger)index {
    UIView *view = self.filterViews[index];
    view.hidden = NO;
    //    view.alpha = 0;
    CGRect rect = view.frame;
    view.frame = CGRectMake(0, self.normalFrame.size.height, view.bounds.size.width, 0);
    [UIView animateWithDuration:0.25 animations:^{
        view.frame = CGRectMake(0, self.normalFrame.size.height, view.bounds.size.width, rect.size.height);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, view.frame.size.height + self.normalFrame.size.height);
        self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height + rect.size.height);
        //        view.alpha = 1;
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, view.frame.size.height + self.normalFrame.size.height);
        //        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [UIScreen mainScreen].bounds.size.height - self.frame.origin.y);
    }];
}

- (void)hideDetailView:(NSInteger)index {
    UIView *view = self.filterViews[index];
    CGRect rect = view.frame;
    [UIView animateWithDuration:0.1 animations:^{
        view.frame = CGRectMake(0, self.normalFrame.size.height, view.bounds.size.width, 0);
        self.frame = self.normalFrame;
        self.superview.frame = CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height - rect.size.height);
        //        view.alpha = 0;
    } completion:^(BOOL finished) {
        view.frame = CGRectMake(0, self.normalFrame.size.height, rect.size.width, rect.size.height);
        view.hidden = YES;
    }];
}

- (LLFilterEventView *)hostView {
    if (!_hostView) {
        _hostView = [[LLFilterEventView alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 100)];
        _hostView.clipsToBounds = YES;
        _hostView.averageCount = 3;
        __weak typeof(self) weakSelf = self;
        _hostView.changeBlock = ^(NSArray *hosts) {
            weakSelf.currentHost = hosts;
            [weakSelf reCalculateFilters];
            [weakSelf updateFilterButton:weakSelf.hostView count:hosts.count];
        };
        [self addSubview:_hostView];
    }
    return _hostView;
}

- (LLFilterEventView *)typeView {
    if (!_typeView) {
        _typeView = [[LLFilterEventView alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 50)];
        _typeView.clipsToBounds = YES;
        _typeView.averageCount = 3;
        LLFilterLabelModel *model1 = [[LLFilterLabelModel alloc] initWithMessage:@"Header"];
        LLFilterLabelModel *model2 = [[LLFilterLabelModel alloc] initWithMessage:@"Body"];
        LLFilterLabelModel *model3 = [[LLFilterLabelModel alloc] initWithMessage:@"Response"];
        [_typeView updateDataArray:@[model1,model2,model3]];
        __weak typeof(self) weakSelf = self;
        _typeView.changeBlock = ^(NSArray *types) {
            weakSelf.currentTypes = types;
            [weakSelf reCalculateFilters];
            [weakSelf updateFilterButton:weakSelf.typeView count:types.count];
        };
        [self addSubview:_typeView];
    }
    return _typeView;
}

- (LLFilterDateView *)dateView {
    if (!_dateView) {
        _dateView = [[LLFilterDateView alloc] initWithFrame:CGRectMake(0, 0, LL_SCREEN_WIDTH, 110)];
        _dateView.clipsToBounds = YES;
        __weak typeof(self) weakSelf = self;
        _dateView.changeBlock = ^(NSDate *from, NSDate *end) {
            weakSelf.currentFromDate = from;
            weakSelf.currentEndDate = end;
            [weakSelf reCalculateFilters];
            NSInteger count = 0;
            count += from ? 1 : 0;
            count += end ? 1 : 0;
            [weakSelf updateFilterButton:weakSelf.dateView count:count];
        };
        [self addSubview:_dateView];
    }
    return _dateView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"Host",@"Filter",@"Date"];
    }
    return _titles;
}

@end
