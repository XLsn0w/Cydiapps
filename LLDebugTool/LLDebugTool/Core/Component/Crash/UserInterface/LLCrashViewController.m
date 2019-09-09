//
//  LLCrashViewController.m
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

#import "LLCrashViewController.h"
#import "LLCrashCell.h"
#import "LLCrashModel.h"
#import "LLConfig.h"
#import "LLCrashHelper.h"
#import "LLStorageManager.h"
#import "LLCrashDetailViewController.h"
#import "LLImageNameConfig.h"
#import "LLToastUtils.h"

static NSString *const kCrashCellID = @"CrashCellID";

@interface LLCrashViewController ()

@end

@implementation LLCrashViewController

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

#pragma mark - Primary
- (void)initial {
    self.navigationItem.title = @"Crash Report";

    // TableView
    [self.tableView registerNib:[UINib nibWithNibName:@"LLCrashCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kCrashCellID];
    
    [self loadData];
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [[LLToastUtils shared] loadingMessage:@"Loading"];
    [[LLStorageManager shared] getModels:[LLCrashModel class] launchDate:nil complete:^(NSArray<LLStorageModel *> *result) {
        [[LLToastUtils shared] hide];
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:result];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - Rewrite
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
            [weakSelf showAlertControllerWithMessage:@"Remove crash model fail" handler:^(NSInteger action) {
                if (action == 1) {
                    [weakSelf loadData];
                }
            }];
        }
    }];
}

#pragma mark - UITableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLCrashCell *cell = [tableView dequeueReusableCellWithIdentifier:kCrashCellID forIndexPath:indexPath];
    [cell confirmWithModel:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (!self.tableView.isEditing) {
        LLCrashDetailViewController *vc = [[LLCrashDetailViewController alloc] init];
        vc.model = self.datas[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UISearchController
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [super searchBar:searchBar textDidChange:searchText];
    if (searchText.length == 0) {
        [self.searchDataArray removeAllObjects];
        [self.searchDataArray addObjectsFromArray:self.dataArray];
        [self.tableView reloadData];
    } else {
        [self.searchDataArray removeAllObjects];
        for (LLCrashModel *model in self.dataArray) {
            if ([model.name.lowercaseString containsString:searchText.lowercaseString] || [model.reason.lowercaseString containsString:searchText.lowercaseString]) {
                [self.searchDataArray addObject:model];
            }
        }
        [self.tableView reloadData];
    }
}

@end
