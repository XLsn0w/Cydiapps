//
//  LLLogViewController.m
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

#import "LLLogViewController.h"
#import "LLLogCell.h"
#import "LLConfig.h"
#import "LLStorageManager.h"
#import "LLLogFilterView.h"
#import "LLMacros.h"
#import "LLLogDetailViewController.h"
#import "LLImageNameConfig.h"
#import "LLSearchBar.h"
#import "NSObject+LL_Utils.h"
#import "LLToastUtils.h"

static NSString *const kLogCellID = @"LLLogCell";

@interface LLLogViewController ()

@property (nonatomic, strong) LLLogFilterView *filterView;

// Data
@property (nonatomic, strong) NSArray *currentLevels;
@property (nonatomic, strong) NSArray *currentEvents;
@property (nonatomic, copy) NSString *currentFile;
@property (nonatomic, copy) NSString *currentFunc;
@property (nonatomic, strong) NSDate *currentFromDate;
@property (nonatomic, strong) NSDate *currentEndDate;
@property (nonatomic, strong) NSArray *currentUserIdentities;

@end

@implementation LLLogViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSearchEnable = YES;
        self.isSelectEnable = YES;
        self.isDeleteEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.filterView cancelFiltering];
}

- (void)rightItemClick:(UIButton *)sender {
    [super rightItemClick:sender];
    [self.filterView cancelFiltering];
}

- (BOOL)isSearching {
    return [super isSearching] || self.currentLevels.count || self.currentEvents.count || self.currentFile.length || self.currentFunc.length || self.currentFromDate || self.currentEndDate || self.currentUserIdentities.count;
}

- (void)deleteFilesWithIndexPaths:(NSArray *)indexPaths {
    [super deleteFilesWithIndexPaths:indexPaths];
    __block NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        [models addObject:self.datas[indexPath.row]];
    }
    __weak typeof(self) weakSelf = self;
    [[LLToastUtils shared] loadingMessage:@"Deleting"];
    [[LLStorageManager shared] removeModels:models complete:^(BOOL result) {
        [[LLToastUtils shared] hide];
        if (result) {
            [weakSelf.dataArray removeObjectsInArray:models];
            [weakSelf.searchDataArray removeObjectsInArray:models];
            [weakSelf.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [weakSelf showAlertControllerWithMessage:@"Remove log model fail" handler:^(NSInteger action) {
                if (action == 1) {
                    [weakSelf loadData];
                }
            }];
        }
    }];
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLLogCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogCellID forIndexPath:indexPath];
    [cell confirmWithModel:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.tableView.isEditing == NO) {
        LLLogDetailViewController *vc = [[LLLogDetailViewController alloc] init];
        vc.model = self.datas[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.searchBar.frame.size.height + 40;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    [self.filterView cancelFiltering];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [super searchBarTextDidBeginEditing:searchBar];
    [self.filterView cancelFiltering];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [super
     searchBar:searchBar textDidChange:searchText];
    [self.filterView cancelFiltering];
    [self filterData];
}

#pragma mark - Primary
- (void)initial {
    self.navigationItem.title = @"Log Tracker";
    
    if (_launchDate == nil) {
        _launchDate = [NSObject LL_launchDate];
    }
        
    // TableView
    [self.tableView registerNib:[UINib nibWithNibName:@"LLLogCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kLogCellID];
    
    self.filterView = [[LLLogFilterView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, LL_SCREEN_WIDTH, 40)];
    __weak typeof(self) weakSelf = self;
    self.filterView.changeBlock = ^(NSArray *levels, NSArray *events, NSString *file, NSString *func, NSDate *from, NSDate *end, NSArray *userIdentities) {
        weakSelf.currentLevels = levels;
        weakSelf.currentEvents = events;
        weakSelf.currentFile = file;
        weakSelf.currentFunc = func;
        weakSelf.currentFromDate= from;
        weakSelf.currentEndDate = end;
        weakSelf.currentUserIdentities = userIdentities;
        [weakSelf filterData];
    };
    [self.filterView configWithData:self.dataArray];
    
    [self.headerView addSubview:self.filterView];
    self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.frame.size.height + self.filterView.frame.size.height);
    
    [self loadData];
}

- (void)loadData {
    self.searchBar.text = nil;
    __weak typeof(self) weakSelf = self;
    [[LLToastUtils shared] loadingMessage:@"Loading"];
    [[LLStorageManager shared] getModels:[LLLogModel class] launchDate:_launchDate complete:^(NSArray<LLStorageModel *> *result) {
        [[LLToastUtils shared] hide];
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:result];
        [weakSelf.searchDataArray removeAllObjects];
        [weakSelf.searchDataArray addObjectsFromArray:weakSelf.dataArray];
        [weakSelf.filterView configWithData:weakSelf.dataArray];
        [weakSelf.tableView reloadData];
    }];
}

- (void)filterData {
    @synchronized (self) {
        [self.searchDataArray removeAllObjects];
        [self.searchDataArray addObjectsFromArray:self.dataArray];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (LLLogModel *model in self.dataArray) {
            // Filter "Search"
            if (self.searchBar.text.length) {
                if (![model.message.lowercaseString containsString:self.searchBar.text.lowercaseString]) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            // Filter Level
            if (self.currentLevels.count) {
                if (![self.currentLevels containsObject:model.levelDescription]) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            // Filter Event
            if (self.currentEvents.count) {
                if (![self.currentEvents containsObject:model.event]) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            // Filter File
            if (self.currentFile.length) {
                if (![model.file isEqualToString:self.currentFile]) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            // Filter Func
            if (self.currentFunc.length) {
                if (![model.function isEqualToString:self.currentFunc]) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            // Filter Date
            if (self.currentFromDate) {
                if ([model.dateDescription compare:self.currentFromDate] == NSOrderedAscending) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            if (self.currentEndDate) {
                if ([model.dateDescription compare:self.currentEndDate] == NSOrderedDescending) {
                    [tempArray addObject:model];
                    continue;
                }
            }
            
            if (self.currentUserIdentities.count) {
                if (![self.currentUserIdentities containsObject:model.userIdentity]) {
                    [tempArray addObject:model];
                    continue;
                }
            }
        }
        [self.searchDataArray removeObjectsInArray:tempArray];
        [self.tableView reloadData];
    }
}

@end
