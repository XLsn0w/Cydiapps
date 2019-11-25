//
//  WBGlobalSettingViewController.m
//  DingTalkAssistant
//
//  Created by buginux on 2017/7/28.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBGlobalSettingViewController.h"
#import "../GPS/WBGPSPickerViewController.h"
#import "../WIFI/WBWifiListViewController.h"

static UIWindow *s_applicationWindow = nil;

@implementation WBGlobalSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.title = @"设置";
    
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
}

+ (void)setApplicationWindow:(UIWindow *)applicationWindow {
    s_applicationWindow = applicationWindow;
}

- (void)doneButtonTapped:(UIButton *)sender {
    [self.delegate globalSettingViewControllerDidFinish:self];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return @"GPS 设置";
    } else {
        return @"WIFI 设置";
    }
}

- (UIViewController *)viewControllerToPushForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [WBGPSPickerViewController new];
    } else {
        return [WBWifiListViewController new];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
    
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewControllerToPush = [self viewControllerToPushForRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:viewControllerToPush animated:YES];
}

@end
