//
//  LLFilterOtherView.m
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

#import "LLFilterOtherView.h"
#import "LLFilterTextFieldCell.h"
#import "LLFilterLabelCell.h"
#import "LLFilterLabelModel.h"
#import "LLMacros.h"
#import "LLFactory.h"
#import "LLConfig.h"
#import "LLFormatterTool.h"
#import "LLThemeManager.h"
#import "LLConst.h"

static NSString *const kHeaderID = @"HeaderID";
static NSString *const kTextFieldCellID = @"TextFieldCellID";
static NSString *const kLabelCellID = @"LabelCellID";

@interface LLFilterOtherView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *userIdDataArray;

@property (nonatomic, strong) NSArray *fileDataArray;

@property (nonatomic, strong) NSDictionary *fileDictionary;

@property (nonatomic, strong) LLFilterTextFieldModel *fileModel;

@property (nonatomic, strong) LLFilterTextFieldModel *funcModel;

@property (nonatomic, strong) LLFilterTextFieldModel *fromDateModel;

@property (nonatomic, strong) LLFilterTextFieldModel *endDateModel;

@end

@implementation LLFilterOtherView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)updateFileDataDictionary:(NSDictionary <NSString *, NSArray *>*)dataDictionary fromDate:(NSDate *)fromDate endDate:(NSDate *)endDate userIdentities:(NSArray *)userIdentities {
    [self.userIdDataArray removeAllObjects];
    for (NSString *userId in userIdentities) {
        LLFilterLabelModel *model = [[LLFilterLabelModel alloc] initWithMessage:userId];
        [self.userIdDataArray addObject:model];
    }
    _fileDataArray = dataDictionary.allKeys;
    _fileDictionary = dataDictionary;
    
    LLFilterTextFieldModel *model = [[LLFilterTextFieldModel alloc] init];
    model.title = @"File";
    model.titleWidth = 60;
    model.filters = dataDictionary.allKeys;
    self.fileModel = model;
    
    LLFilterTextFieldModel *model2 = [[LLFilterTextFieldModel alloc] init];
    model2.title = @"Function";
    model2.titleWidth = 60;
    model2.filters = nil;
    self.funcModel = model2;
    
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
    
    
    CGFloat headerHeight = 30;
    CGFloat gap = kLLGeneralMargin;
    CGFloat itemHeight = 25;
    NSInteger idCount = ceilf(self.userIdDataArray.count / 3.0);
    CGFloat height = headerHeight + gap + itemHeight + gap + itemHeight + gap + headerHeight + gap + itemHeight + gap + itemHeight + gap + headerHeight + gap + idCount * (itemHeight + gap);
    if (height > LL_SCREEN_HEIGHT / 2.0) {
        height = LL_SCREEN_HEIGHT / 2.0;
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    [self.collectionView reloadData];
}

- (void)reCalculateFilters {
    if (_changeBlock) {
        NSDate *fromDate = [[LLFormatterTool shared] dateFromString:_fromDateModel.currentFilter style:FormatterToolDateStyle3];
        NSDate *endDate = [[LLFormatterTool shared] dateFromString:_endDateModel.currentFilter style:FormatterToolDateStyle3];
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        
        for (LLFilterLabelModel *model in self.userIdDataArray) {
            if (model.isSelected) {
                [userIds addObject:model.message];
            }
        }
        
        _changeBlock(_fileModel.currentFilter,
                     _funcModel.currentFilter,
                     fromDate,endDate,
                     userIds);
    }
}

- (void)updateFuncModel {
    NSString *filter = self.fileModel.currentFilter;
    self.funcModel = [[LLFilterTextFieldModel alloc] init];
    self.funcModel.titleWidth = 60;
    self.funcModel.title = @"Function";
    if (filter) {
        NSArray *filters = self.fileDictionary[filter];
        self.funcModel.filters = filters;
        self.funcModel.currentFilter = nil;
    } else {
        self.funcModel.filters = nil;
        self.funcModel.currentFilter = nil;
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 2;
    }
    return self.userIdDataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // 0 -> File Function
    // 1 -> Date
    // 2 -> userIdentity
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0 || indexPath.section == 1) {
        LLFilterTextFieldCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTextFieldCellID forIndexPath:indexPath];
        if (indexPath.section == 0) {
            // File
            if (indexPath.row == 0) {
                [cell confirmWithModel:self.fileModel];
                cell.confirmBlock = ^{
                    [weakSelf updateFuncModel];
                    [weakSelf reCalculateFilters];
                };
            } else {
                [cell confirmWithModel:self.funcModel];
                cell.confirmBlock = ^{
                    [weakSelf reCalculateFilters];
                };
            }
        } else if (indexPath.section == 1) {
            // Date
            if (indexPath.row == 0) {
                [cell confirmWithModel:self.fromDateModel];
            } else {
                [cell confirmWithModel:self.endDateModel];
            }
            cell.confirmBlock = ^{
                [weakSelf reCalculateFilters];
            };
        }
        return cell;
    }
    LLFilterLabelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLabelCellID forIndexPath:indexPath];
    [cell confirmWithModel:self.userIdDataArray[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        LLFilterLabelModel *model = self.userIdDataArray[indexPath.item];
        model.isSelected = !model.isSelected;
        LLFilterLabelCell *cell = (LLFilterLabelCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell confirmWithModel:model];
        [self reCalculateFilters];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        static NSInteger labelTag = 1000;
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kHeaderID forIndexPath:indexPath];
        view.backgroundColor = [[LLThemeManager shared].primaryColor colorWithAlphaComponent:0.2];
        if (![view viewWithTag:labelTag]) {
            UILabel *label = [LLFactory getLabel:view frame:CGRectMake(12, 0, view.frame.size.width - 12, view.frame.size.height) text:nil font:13 textColor:[LLThemeManager shared].primaryColor];
            label.font = [UIFont boldSystemFontOfSize:13];
            label.textColor = [LLThemeManager shared].primaryColor;
            label.tag = labelTag;
            [view addSubview:label];
        }
        UILabel *label = [view viewWithTag:labelTag];
        if (indexPath.section == 0) {
            label.text = @"FILE";
        } else if (indexPath.section == 1) {
            label.text = @"DATE";
        } else if (indexPath.section == 2) {
            label.text = @"USERIDENTITY";
        }
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
    if (section == 0 || section == 1) {
        return 0;
    }
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0 || section == 1) {
        return UIEdgeInsetsMake(10, 0, 10, 0);
    }
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return CGSizeMake(LL_SCREEN_WIDTH, 25);
    }
    return CGSizeMake((LL_SCREEN_WIDTH - 5 * 10) / 3.0, 30);
}

#pragma mark - Primary
- (void)initial {
    self.userIdDataArray = [[NSMutableArray alloc] init];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionView = [LLFactory getCollectionView:self frame:self.bounds delegate:self layout:layout];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [[LLThemeManager shared].backgroundColor colorWithAlphaComponent:0.75];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LLFilterTextFieldCell" bundle:[LLConfig shared].XIBBundle] forCellWithReuseIdentifier:kTextFieldCellID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LLFilterLabelCell" bundle:[LLConfig shared].XIBBundle] forCellWithReuseIdentifier:kLabelCellID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderID];
    [LLFactory lineView:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1) superView:self];
}

@end
