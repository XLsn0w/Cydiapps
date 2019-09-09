//
//  TestLogViewController.m
//  LLDebugToolDemo
//
//  Created by admin10000 on 2018/8/29.
//  Copyright © 2018年 li. All rights reserved.
//

#import "TestLogViewController.h"
#import "LLDebugToolMacros.h"

@interface TestLogViewController ()

@end

@implementation TestLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.log", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"insert.log", nil);
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"insert.error.log", nil);
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"insert.call.log", nil);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self testNormalLog];
    } else if (indexPath.row == 1) {
        [self testErrorLog];
    } else if (indexPath.row == 2) {
        [self testEventLog];
    }
}

#pragma mark - Actions
- (void)testNormalLog {
    LLog(NSLocalizedString(@"normal.log.info", nil));
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionLog];
}

- (void)testErrorLog {
    LLog_Error(NSLocalizedString(@"error.log.info", nil));
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionLog];
}

- (void)testEventLog {
    LLog_Error_Event(NSLocalizedString(@"call", nil),NSLocalizedString(@"call.log.info", nil));
    [[LLDebugTool sharedTool] executeAction:LLDebugToolActionLog];
}

@end
