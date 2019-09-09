//
//  LLSandboxViewController.m
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

#import "LLSandboxViewController.h"
#import "LLSandboxCell.h"
#import "LLSandboxHelper.h"
#import "LLPreviewController.h"
#import "LLConfig.h"
#import "LLImageNameConfig.h"
#import "LLUITableViewLongPressGestureRecognizerDelegate.h"
#import "LLToastUtils.h"

static NSString *const kSandboxCellID = @"LLSandboxCell";

@interface LLSandboxViewController () <LLUITableViewLongPressGestureRecognizerDelegate>

@end

@implementation LLSandboxViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSearchEnable = YES;
        self.isSelectEnable = YES;
        self.isShareEnable = YES;
        self.isDeleteEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)shareFilesWithIndexPaths:(NSArray *)indexPaths {
    [super shareFilesWithIndexPaths:indexPaths];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        LLSandboxModel *model = self.datas[indexPath.row];
        [array addObject:[NSURL fileURLWithPath:model.filePath]];
    }
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:nil];
    __weak typeof(self) weakSelf = self;
    vc.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        [weakSelf rightItemClick:weakSelf.navigationItem.rightBarButtonItem.customView];
        if (activityError) {
            [[LLToastUtils shared] toastMessage:activityError.debugDescription];
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Primary
/**
 * initial method
 */
- (void)initial {
    // Data source
    if (_sandboxModel == nil) {
        _sandboxModel = [[LLSandboxHelper shared] getCurrentSandboxStructure];
    }
    if (self.sandboxModel.isHomeDirectory) {
        self.navigationItem.title = @"Sandbox";
    } else {
        self.navigationItem.title = self.sandboxModel.name;
    }
    // TableView
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSandboxCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kSandboxCellID];
}

- (void)deleteFilesWithIndexPaths:(NSArray *)indexPaths {
    [super deleteFilesWithIndexPaths:indexPaths];
    NSMutableArray *finishedModels = [[NSMutableArray alloc] init];
    NSMutableArray *finishedIndexPaths = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in indexPaths) {
        LLSandboxModel *model = self.datas[indexPath.row];
        BOOL ret = [self deleteFile:model];
        if (ret) {
            [finishedModels addObject:model];
            [finishedIndexPaths addObject:indexPath];
        }
    }
    [self.dataArray removeObjectsInArray:finishedModels];
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
}

- (NSMutableArray *)dataArray {
    return self.sandboxModel.subModels;
}

- (BOOL)deleteFile:(LLSandboxModel *)model {
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:model.filePath]) {
        BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:model.filePath error:&error];
        if (!ret) {
            [self showAlertControllerWithMessage:[NSString stringWithFormat:@"Delete file fail\nFilePath:%@\nError:%@",model.filePath,error.localizedDescription] handler:nil];
        }
        return ret;
    }
    return YES;
}

#pragma mark - TableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLSandboxCell *cell = [tableView dequeueReusableCellWithIdentifier:kSandboxCellID forIndexPath:indexPath];
    if (TARGET_IPHONE_SIMULATOR) {
        cell.delegate = self;
    }
    [cell confirmWithModel:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (self.tableView.isEditing == NO) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        LLSandboxModel *model = self.datas[indexPath.row];
        if (model.isDirectory) {
            if (model.subModels.count) {
                LLSandboxViewController *vc = [[LLSandboxViewController alloc] init];
                vc.sandboxModel = model;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [[LLToastUtils shared] toastMessage:@"Empty folder"];
            }
        } else {
            if (model.canPreview) {
                LLPreviewController *vc = [[LLPreviewController alloc] init];
                NSMutableArray *paths = [[NSMutableArray alloc] init];
                NSInteger index = 0;
                for (LLSandboxModel *mod in self.datas) {
                    if (mod == model) {
                        [paths addObject:mod.filePath];
                        index = [paths indexOfObject:mod.filePath];
                    } else if (mod.canPreview) {
                        [paths addObject:mod.filePath];
                    }
                }
                vc.filePaths = paths;
                vc.currentPreviewItemIndex = index;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:model.filePath]] applicationActivities:nil];
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [super searchBar:searchBar textDidChange:searchText];
    if (searchText.length == 0) {
        [self.searchDataArray removeAllObjects];
        [self.searchDataArray addObjectsFromArray:self.dataArray];
        [self.tableView reloadData];
    } else {
        [self.searchDataArray removeAllObjects];
        for (LLSandboxModel *model in self.dataArray) {
            [self.searchDataArray addObjectsFromArray:[self modelsByFilter:searchText.lowercaseString model:model]];
        }
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)modelsByFilter:(NSString *)filter model:(LLSandboxModel *)model {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([model.name.lowercaseString containsString:filter]) {
        [array addObject:model];
    }
    for (LLSandboxModel *subModel in model.subModels) {
        [array addObjectsFromArray:[self modelsByFilter:filter model:subModel]];
    }
    return array;
}

#pragma mark - LLUITableViewLongPressGestureRecognizerDelegate
- (void)LL_tableViewCellDidLongPress:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    LLSandboxModel *model = self.datas[indexPath.row];
    [UIPasteboard generalPasteboard].string = model.filePath;
    [[LLToastUtils shared] toastMessage:[NSString stringWithFormat:@"Copy File Path Success\n%@",model.filePath]];
}

@end
