//
//  LLCrashDetailViewController.m
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

#import "LLCrashDetailViewController.h"
#import "LLSubTitleTableViewCell.h"
#import "LLMacros.h"
#import "LLStorageManager.h"
#import "LLConfig.h"
#import "LLCrashSignalDetailViewController.h"
#import "LLToastUtils.h"
#import "LLNetworkViewController.h"
#import "LLLogViewController.h"
#import "LLLogModel.h"
#import "LLNetworkModel.h"

static NSString *const kCrashContentCellID = @"CrashContentCellID";

@interface LLCrashDetailViewController () <LLSubTitleTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic, strong) NSArray *canCopyArray;

@end

@implementation LLCrashDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCrashContentCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.contentText = self.contentArray[indexPath.row];
    cell.delegate = self;
    NSString *title = self.titleArray[indexPath.row];
    if ([title isEqualToString:@"Logs"] || [title isEqualToString:@"Network Requests"] || [title hasPrefix:@"Signal"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titleArray[indexPath.row];
    if ([title isEqualToString:@"Logs"]) {
        LLLogViewController *vc = [[LLLogViewController alloc] init];
        vc.launchDate = self.model.launchDate;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"Network Requests"]) {
        LLNetworkViewController *vc = [[LLNetworkViewController alloc] init];
        vc.launchDate = self.model.launchDate;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title hasPrefix:@"Signal"]) {
        NSInteger index = 0;
        for (NSString *str in self.titleArray) {
            if ([str isEqualToString:title]) {
                break;
            } else if ([str hasPrefix:@"Signal"]) {
                index++;
            }
        }
        LLCrashSignalDetailViewController *vc = [[LLCrashSignalDetailViewController alloc] init];
        vc.model = self.model.signals[index];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([self.canCopyArray containsObject:title]) {
        [[UIPasteboard generalPasteboard] setString:self.contentArray[indexPath.row]];
        [[LLToastUtils shared] toastMessage:[NSString stringWithFormat:@"Copy \"%@\" Success",title]];
    }
}

- (void)LLSubTitleTableViewCell:(LLSubTitleTableViewCell *)cell didSelectedContentView:(UITextView *)contentTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Primary
- (void)initial {
    self.navigationItem.title = self.model.name;
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kCrashContentCellID];
    
    self.titleArray = [[NSMutableArray alloc] init];
    self.contentArray = [[NSMutableArray alloc] init];
    
    [self loadData];
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    [[LLToastUtils shared] loadingMessage:@"Loading"];
    [[LLStorageManager shared] getModels:[LLLogModel class] launchDate:_model.launchDate complete:^(NSArray<LLStorageModel *> *result) {
        // Get log models.
        __block NSArray *logs = result;
        [[LLStorageManager shared] getModels:[LLNetworkModel class] launchDate:weakSelf.model.launchDate complete:^(NSArray<LLStorageModel *> *result) {
            [[LLToastUtils shared] hide];
            // Get nework requests.
            NSArray *networkRequests = result;
            [weakSelf updateDataWithLogs:logs networkRequests:networkRequests];
        }];
    }];
}

- (void)updateDataWithLogs:(NSArray *)logs networkRequests:(NSArray *)networkRequests {
    [self.titleArray removeAllObjects];
    [self.contentArray removeAllObjects];
    
    if (_model.name) {
        [self.titleArray addObject:@"Name"];
        [self.contentArray addObject:_model.name];
    }
    if (_model.reason) {
        [self.titleArray addObject:@"Reason"];
        [self.contentArray addObject:_model.reason];
    }
    if (_model.date) {
        [self.titleArray addObject:@"Date"];
        [self.contentArray addObject:_model.date];
    }
    
    if (logs.count) {
        [self.titleArray addObject:@"Logs"];
        [self.contentArray addObject:[NSString stringWithFormat:@"%ld logs",(unsigned long)logs.count]];
    }
    
    if (networkRequests.count) {
        [self.titleArray addObject:@"Network Requests"];
        [self.contentArray addObject:[NSString stringWithFormat:@"%ld network requests",(unsigned long)networkRequests.count]];
    }
    
    for (LLCrashSignalModel *signal in _model.signals) {
        [self.titleArray addObject:[NSString stringWithFormat:@"Signal (%@)",signal.name]];
        [self.contentArray addObject:_model.date];
    }
    
    if (_model.userIdentity) {
        [self.titleArray addObject:@"User Identity"];
        [self.contentArray addObject:_model.userIdentity];
    }
    if (_model.stackSymbols.count) {
        [self.titleArray addObject:@"Stack Symbols"];
        NSMutableString *mutStr = [[NSMutableString alloc] init];
        for (NSString *symbol in _model.stackSymbols) {
            [mutStr appendFormat:@"%@\n\n",symbol];
        }
        [self.contentArray addObject:mutStr];
    }
    if (_model.userInfo.allKeys.count) {
        [self.titleArray addObject:@"UserInfo"];
        NSMutableString *content = [[NSMutableString alloc] init];
        for (NSString *key in _model.userInfo.allKeys) {
            [content appendFormat:@"%@ : %@\n",key,_model.userInfo[key]];
        }
        [self.contentArray addObject:content];
    }
    if (_model.appInfos.count) {
        [self.titleArray addObject:@"App Infos"];
        NSMutableString *str = [[NSMutableString alloc] init];
        for (NSArray *array in _model.appInfos) {
            for (NSDictionary *dic in array) {
                for (NSString *key in dic) {
                    [str appendFormat:@"%@ : %@\n",key,dic[key]];
                }
            }
            [str appendString:@"\n"];
        }
        [self.contentArray addObject:str];
    }
    [self.tableView reloadData];
}

- (NSArray *)canCopyArray {
    if (!_canCopyArray) {
        _canCopyArray = @[@"Name",@"Reason",@"Stack Symbols"];
    }
    return _canCopyArray;
}

@end
