//
//  LLLogDetailViewController.m
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

#import "LLLogDetailViewController.h"
#import "LLSubTitleTableViewCell.h"
#import "LLToastUtils.h"

static NSString *const kLogContentCellID = @"LogContentCellID";

@interface LLLogDetailViewController () <LLSubTitleTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic, strong) NSArray *canCopyArray;

@end

@implementation LLLogDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *content = self.contentArray[indexPath.row];
    LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLogContentCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.contentText = content;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titleArray[indexPath.row];
    if ([self.canCopyArray containsObject:title]) {
        NSString *content = self.contentArray[indexPath.row];
        [UIPasteboard generalPasteboard].string = content;
        [[LLToastUtils shared] toastMessage:[NSString stringWithFormat:@"Copy \"%@\" Success",title]];
    }
}

#pragma mark - LLSubTitleTableViewCellDelegate
- (void)LLSubTitleTableViewCell:(LLSubTitleTableViewCell *)cell didSelectedContentView:(UITextView *)contentTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Primary
/**
 * initial method
 */
- (void)initial {
    self.navigationItem.title = @"Details";
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kLogContentCellID];
    [self loadData];
}

- (void)loadData {
    if (self.model) {
        self.titleArray = [[NSMutableArray alloc] init];
        self.contentArray = [[NSMutableArray alloc] init];
        [self.titleArray addObject:@"Message"];
        [self.contentArray addObject:self.model.message?:@"None message"];
        if (self.model.file.length) {
            [self.titleArray addObject:@"File"];
            [self.contentArray addObject:self.model.file];
        }
        if (self.model.function.length) {
            [self.titleArray addObject:@"Function"];
            [self.contentArray addObject:self.model.function];
        }
        if (self.model.lineNo) {
            [self.titleArray addObject:@"LineNo"];
            [self.contentArray addObject:@(self.model.lineNo).stringValue];
        }
        
        if (self.model.event.length) {
            [self.titleArray addObject:@"Event"];
            [self.contentArray addObject:self.model.event];
        }
        
        if (self.model.date.length) {
            [self.titleArray addObject:@"Date"];
            [self.contentArray addObject:self.model.date];
        }
        
        [self.titleArray addObject:@"Level"];
        [self.contentArray addObject:self.model.levelDescription];

        if (self.model.userIdentity.length) {
            [self.titleArray addObject:@"UserIdentity"];
            [self.contentArray addObject:self.model.userIdentity];
        }
    }
}

- (NSArray *)canCopyArray {
    if (!_canCopyArray) {
        _canCopyArray = @[@"Message",@"File",@"Function"];
    }
    return _canCopyArray;
}

@end
