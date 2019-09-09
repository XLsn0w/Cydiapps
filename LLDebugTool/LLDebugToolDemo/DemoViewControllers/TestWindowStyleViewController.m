//
//  TestWindowStyleViewController.m
//  LLDebugToolDemo
//
//  Created by admin10000 on 2018/8/29.
//  Copyright © 2018年 li. All rights reserved.
//

#import "TestWindowStyleViewController.h"
#import "LLDebugTool.h"

@interface TestWindowStyleViewController ()

@end

@implementation TestWindowStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.window.style", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Use \"LLConfigWindowSuspensionBall\"";
        cell.accessoryType = [LLConfig shared].entryWindowStyle == LLConfigEntryWindowStyleSuspensionBall ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Use \"LLConfigWindowPowerBar\"";
        cell.accessoryType = [LLConfig shared].entryWindowStyle == LLConfigEntryWindowStylePowerBar ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Use \"LLConfigWindowNetBar\"";
        cell.accessoryType = [LLConfig shared].entryWindowStyle == LLConfigEntryWindowStyleNetBar ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self testSuspensionBallWindowStyle];
    } else if (indexPath.row == 1) {
        [self testPowerBarWindowStyle];
    } else if (indexPath.row == 2) {
        [self testNetBarWindowStyle];
    }
    [tableView reloadData];
}

#pragma mark - Actions
- (void)testSuspensionBallWindowStyle {
    [LLConfig shared].entryWindowStyle = LLConfigEntryWindowStyleSuspensionBall;
}

- (void)testPowerBarWindowStyle {
    [LLConfig shared].entryWindowStyle = LLConfigEntryWindowStylePowerBar;
}

- (void)testNetBarWindowStyle {
    [LLConfig shared].entryWindowStyle = LLConfigEntryWindowStyleNetBar;
}

@end
