//
//  LLAppInfoViewController.m
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

#import "LLAppInfoViewController.h"
#import "LLBaseTableViewCell.h"
#import "LLAppInfoHelper.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLFactory.h"
#import "LLThemeManager.h"

static NSString *const kAppInfoCellID = @"AppInfoCellID";
static NSString *const kAppInfoHeaderID = @"AppInfoHeaderID";

@interface LLAppInfoViewController ()

@end

@implementation LLAppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:[[LLAppInfoHelper shared] appInfos]];
    self.navigationItem.title = [UIDevice currentDevice].name ? : @"App Infos";
    [self registerLLAppInfoHelperNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterLLAppInfoHelperNotification];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Primary
- (void)initial {
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kAppInfoHeaderID];
}

#pragma mark - LLAppInfoHelperNotification
- (void)registerLLAppInfoHelperNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLLAppInfoHelperDidUpdateAppInfosNotification:) name:LLAppInfoHelperDidUpdateAppInfosNotificationName object:nil];
}

- (void)unregisterLLAppInfoHelperNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LLAppInfoHelperDidUpdateAppInfosNotificationName object:nil];
}

- (void)didReceiveLLAppInfoHelperDidUpdateAppInfosNotification:(NSNotification *)notifi {
    NSArray *dynamic = notifi.object;
    [self.dataArray replaceObjectAtIndex:0 withObject:dynamic];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAppInfoCellID];
    if (!cell) {
        cell = [[LLBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAppInfoCellID];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        cell.detailTextLabel.minimumScaleFactor = 0.5;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    cell.textLabel.text = dic.allKeys.firstObject;
    cell.detailTextLabel.text = dic.allValues.firstObject;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kAppInfoHeaderID];
    view.frame = CGRectMake(0, 0, LL_SCREEN_WIDTH, 30);
    if (view.backgroundView == nil) {
        view.backgroundView = [LLFactory getPrimaryView:nil frame:view.bounds alpha:0.2];
    }

    if (section == 0) {
        view.textLabel.text = @"Dynamic Information";
    } else if (section == 1) {
        view.textLabel.text = @"Application Information";
    } else if (section == 2) {
        view.textLabel.text = @"Device Information";
    }
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    if (![header.textLabel.textColor isEqual:[LLThemeManager shared].primaryColor]) {
        header.textLabel.textColor = [LLThemeManager shared].primaryColor;
    }
}

@end
