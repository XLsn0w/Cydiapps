//
//  LLCrashSignalDetailViewController.m
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

#import "LLCrashSignalDetailViewController.h"
#import "LLSubTitleTableViewCell.h"
#import "LLConfig.h"
#import "LLToastUtils.h"

static NSString *const kCrashSignalContentCellID = @"CrashSignalContentCellID";

@interface LLCrashSignalDetailViewController ()<LLSubTitleTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic, strong) NSArray *canCopyArray;

@end

@implementation LLCrashSignalDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCrashSignalContentCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.contentText = self.contentArray[indexPath.row];
    cell.delegate = self;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titleArray[indexPath.row];
    if ([self.canCopyArray containsObject:title]) {
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
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kCrashSignalContentCellID];
    
    self.titleArray = [[NSMutableArray alloc] init];
    self.contentArray = [[NSMutableArray alloc] init];
    
    [self loadData];
}

- (void)loadData {

    [self.titleArray removeAllObjects];
    [self.contentArray removeAllObjects];
    
    if (_model.name) {
        [self.titleArray addObject:@"Name"];
        [self.contentArray addObject:_model.name];
    }

    if (_model.date) {
        [self.titleArray addObject:@"Date"];
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

    if (_model.appInfos.count) {
        [self.titleArray addObject:@"App Infos"];
        NSMutableString *str = [[NSMutableString alloc] init];
        for (NSString *key in _model.appInfos) {
            [str appendFormat:@"%@ : %@\n",key,_model.appInfos[key]];
        }
        [self.contentArray addObject:str];
    }
    [self.tableView reloadData];
}

- (NSArray *)canCopyArray {
    if (!_canCopyArray) {
        _canCopyArray = @[@"Name",@"Stack Symbols"];
    }
    return _canCopyArray;
}


@end
