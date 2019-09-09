//
//  TestColorStyleViewController.m
//  LLDebugToolDemo
//
//  Created by admin10000 on 2018/8/29.
//  Copyright © 2018年 li. All rights reserved.
//

#import "TestColorStyleViewController.h"
#import "LLDebugTool.h"

@interface TestColorStyleViewController ()

@end

@implementation TestColorStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.color.style", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Use \"LLConfigColorStyleHack\"";
        cell.accessoryType = [LLConfig shared].colorStyle == LLConfigColorStyleHack ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Use \"LLConfigColorStyleSimple\"";
        cell.accessoryType = [LLConfig shared].colorStyle == LLConfigColorStyleSimple ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Use \"LLConfigColorStyleSystem\"";
        cell.accessoryType = [LLConfig shared].colorStyle == LLConfigColorStyleSystem ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Use \"[[LLConfig sharedConfig] configBackgroundColor:[UIColor orangeColor] textColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleDefault]\"";
        cell.accessoryType = [LLConfig shared].colorStyle == LLConfigColorStyleCustom ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self testHackColorStyle];
    } else if (indexPath.row == 1) {
        [self testSimpleColorSytle];
    } else if (indexPath.row == 2) {
        [self testSystemColorStyle];
    } else if (indexPath.row == 3) {
        [self testCustomColorConfig];
    }
    [tableView reloadData];
}

#pragma mark - Actions
- (void)testHackColorStyle {
    [LLConfig shared].colorStyle = LLConfigColorStyleHack;
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionNetwork];
}

- (void)testSimpleColorSytle {
    [LLConfig shared].colorStyle = LLConfigColorStyleSimple;
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionNetwork];
}

- (void)testSystemColorStyle {
    [LLConfig shared].colorStyle = LLConfigColorStyleSystem;
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionNetwork];
}

- (void)testCustomColorConfig {
    [[LLConfig shared] configBackgroundColor:[UIColor orangeColor] primaryColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleDefault];
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionNetwork];
}

@end
