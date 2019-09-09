//
//  LLFilterDateView.m
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

#import "LLFilterDateView.h"
#import "LLFilterTextFieldCell.h"
#import "LLMacros.h"
#import "LLFormatterTool.h"
#import "LLConfig.h"
#import "LLFactory.h"
#import "LLThemeManager.h"

static NSString *const kHeaderID = @"HeaderID";
static NSString *const kTextFieldCellID = @"TextFieldCellID";

@interface LLFilterDateView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *fileDataArray;

@property (nonatomic, strong) LLFilterTextFieldModel *fromDateModel;

@property (nonatomic, strong) LLFilterTextFieldModel *endDateModel;

@end

@implementation LLFilterDateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)updateFromDate:(NSDate *)fromDate endDate:(NSDate *)endDate {

    self.fromDateModel = [[LLFilterTextFieldModel alloc] init];
    self.fromDateModel.title = @"From";
    self.fromDateModel.titleWidth = 60;
    self.fromDateModel.useDatePicker = YES;
    self.fromDateModel.fromDate = fromDate;
    self.fromDateModel.endDate = endDate;
    
    self.endDateModel = [[LLFilterTextFieldModel alloc] init];
    self.endDateModel.title = @"To";
    self.endDateModel.titleWidth = 60;
    self.endDateModel.useDatePicker = YES;
    self.endDateModel.fromDate = fromDate;
    self.endDateModel.endDate = endDate;

    [self.collectionView reloadData];
}

- (void)reCalculateFilters {
    if (_changeBlock) {
        NSDate *fromDate = [[LLFormatterTool shared] dateFromString:_fromDateModel.currentFilter style:FormatterToolDateStyle3];
        NSDate *endDate = [[LLFormatterTool shared] dateFromString:_endDateModel.currentFilter style:FormatterToolDateStyle3];
        _changeBlock(fromDate,endDate);
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    LLFilterTextFieldCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTextFieldCellID forIndexPath:indexPath];
    // Date
    if (indexPath.row == 0) {
        [cell confirmWithModel:self.fromDateModel];
    } else {
        [cell confirmWithModel:self.endDateModel];
    }
    cell.confirmBlock = ^{
        [weakSelf reCalculateFilters];
    };
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        static NSInteger labelTag = 1000;
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];
        view.backgroundColor = [[LLThemeManager shared].primaryColor colorWithAlphaComponent:0.2];

        if (![view viewWithTag:labelTag]) {
            UILabel *label = [LLFactory getLabel:view frame:CGRectMake(12, 0, view.frame.size.width - 12, view.frame.size.height)];
            label.font = [UIFont boldSystemFontOfSize:13];
            label.textColor = [LLThemeManager shared].primaryColor;
            label.tag = labelTag;
            [view addSubview:label];
        }
        UILabel *label = [view viewWithTag:labelTag];
        label.text = @"DATE";
        return view;
    }
    return [[UICollectionReusableView alloc] init];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(LL_SCREEN_WIDTH, 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 0, 10, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(LL_SCREEN_WIDTH, 25);
}

#pragma mark - Primary
- (void)initial {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [LLFactory getCollectionView:self frame:self.bounds delegate:self layout:layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [LLThemeManager shared].backgroundColor;
    [self.collectionView registerNib:[UINib nibWithNibName:@"LLFilterTextFieldCell" bundle:[LLConfig shared].XIBBundle] forCellWithReuseIdentifier:kTextFieldCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderID];
    [LLFactory lineView:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1) superView:self];
}

@end
