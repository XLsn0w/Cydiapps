//
//  LLNetworkViewController.m
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

#import "LLNetworkViewController.h"
#import "LLNetworkCell.h"
#import "LLNetworkModel.h"
#import "LLStorageManager.h"
#import "LLNetworkDetailViewController.h"
#import "LLImageNameConfig.h"
#import "LLConfig.h"
#import "LLNetworkFilterView.h"
#import "LLSearchBar.h"
#import "LLNetworkFilterView.h"
#import "LLMacros.h"
#import "NSObject+LL_Utils.h"
#import "LLToastUtils.h"

static NSString *const kNetworkCellID = @"NetworkCellID";

@interface LLNetworkViewController ()

@property (nonatomic, strong) LLNetworkFilterView *filterView;

// Data
@property (nonatomic, strong) NSArray *currentHost;
@property (nonatomic, strong) NSArray *currentTypes;
@property (nonatomic, strong) NSDate *currentFromDate;
@property (nonatomic, strong) NSDate *currentEndDate;

@end

@implementation LLNetworkViewController

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
    return [super isSearching] || self.currentHost.count || self.currentTypes.count || self.currentFromDate || self.currentEndDate;
}

- (void)deleteFilesWithIndexPaths:(NSArray *)indexPaths {
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
            [weakSelf showAlertControllerWithMessage:@"Remove network model fail" handler:^(NSInteger action) {
                if (action == 1) {
                    [weakSelf loadData];
                }
            }];
        }
    }];
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkCellID forIndexPath:indexPath];
    [cell confirmWithModel:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.tableView.isEditing == NO) {
        LLNetworkDetailViewController *vc = [[LLNetworkDetailViewController alloc] init];
        vc.model = self.datas[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [super tableView:tableView heightForHeaderInSection:section] + 40;
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
    self.navigationItem.title = @"Network Monitoring";
    
    if (_launchDate == nil) {
        _launchDate = [NSObject LL_launchDate];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LLNetworkCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kNetworkCellID];
    
    self.filterView = [[LLNetworkFilterView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, LL_SCREEN_WIDTH, 40)];
    __weak typeof(self) weakSelf = self;
    self.filterView.changeBlock = ^(NSArray *hosts, NSArray *types, NSDate *from, NSDate *end) {
        weakSelf.currentHost = hosts;
        weakSelf.currentTypes = types;
        weakSelf.currentFromDate = from;
        weakSelf.currentEndDate = end;
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
    [[LLStorageManager shared] getModels:[LLNetworkModel class] launchDate:_launchDate complete:^(NSArray<LLStorageModel *> *result) {
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
        for (LLNetworkModel *model in self.dataArray) {

            // Filter Host
            if (self.currentHost.count) {
                NSString *host = model.url.host;
                if (![self.currentHost containsObject:host]) {
                    [tempArray addObject:model];
                    continue;
                }
            }

            // Filter "Search"
            if (self.searchBar.text.length) {
                NSMutableArray *filterArray = [[NSMutableArray alloc] initWithObjects:model.url.absoluteString ?:model.url.host, nil];
                BOOL checkHeader = [self.currentTypes containsObject:@"Header"];
                BOOL checkBody = [self.currentTypes containsObject:@"Body"];
                BOOL checkResponse = [self.currentTypes containsObject:@"Response"];
                BOOL needPop = YES;
                
                if (checkHeader && model.headerString.length) {
                    [filterArray addObject:model.headerString];
                }
                
                if (checkBody && model.requestBody.length) {
                    [filterArray addObject:model.requestBody];
                }
                
                if (checkResponse && model.responseString.length) {
                    [filterArray addObject:model.responseString];
                }
                
                for (NSString *filter in filterArray) {
                    if ([filter.lowercaseString containsString:self.searchBar.text.lowercaseString]) {
                        needPop = NO;
                        break;
                    }
                }
                
                if (needPop) {
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
        }
        [self.searchDataArray removeObjectsInArray:tempArray];
        [self.tableView reloadData];
    }
}

@end
