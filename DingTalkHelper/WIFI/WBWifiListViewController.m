//
//  WBWifiListViewController.m
//  DingTalkAssistant
//
//  Created by buginux on 2017/7/28.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBWifiListViewController.h"
#import "WBWifiStore.h"
#import "WBWifiModel.h"

@interface WBWifiListViewController ()

@property (nonatomic, strong) WBWifiStore *store;
@property (nonatomic, strong) WBWifiModel *selectedWifi;

@end

@implementation WBWifiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WIFI 设置";
    
    self.store = [WBWifiStore sharedStore];
    [self.store fetchCurrentWifi];
    [self.store fetchHistoryWifi];
    for (WBWifiModel *wifi in self.store.historyWifiList) {
        if (wifi.selected) {
            self.selectedWifi = wifi;
        }
    }
    [self.tableView reloadData];
}


- (NSString *)titleForSection:(NSInteger)section {
    if (section == 0) {
        return @"当前 Wifi";
    } else {
        return @"历史 Wifi";
    }
}

- (WBWifiModel *)wifiForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.store.currentWifiList[indexPath.row];
    } else if (indexPath.section == 1) {
        return self.store.historyWifiList[indexPath.row];
    }
    return nil;
}

- (void)selectWifi:(WBWifiModel *)currentWifi {
    for (WBWifiModel *wifi in self.store.currentWifiList) {
        wifi.selected = (wifi == currentWifi);
    }
    for (WBWifiModel *wifi in self.store.historyWifiList) {
        wifi.selected = (wifi == currentWifi);
    }
    
    if (![self.store wifiHooked]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"初次设置需重启后才会生效" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"重启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    self.selectedWifi = currentWifi;
    [self.store hookWifi:currentWifi];
    [self.store appendHistoryWifi:currentWifi];
    [self.store saveHistoryWifi];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSection = 0;
    
    if ([self.store.currentWifiList count] > 0) {
        numberOfSection += 1;
    }
    
    if ([self.store.historyWifiList count] > 0) {
        numberOfSection += 1;
    }
   
    return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.store.currentWifiList count];
    } else if (section == 1) {
        return [self.store.historyWifiList count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    WBWifiModel *wifi = [self wifiForRowAtIndexPath:indexPath];
    cell.textLabel.text = wifi.wifiName;
    cell.accessoryType = wifi.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForSection:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WBWifiModel *selectedWifi = [self wifiForRowAtIndexPath:indexPath];
    if ([self.selectedWifi isEqual:selectedWifi]) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"确定将钉钉的 WIFI 切换为 %@ 吗？", selectedWifi.wifiName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    __unsafe_unretained __typeof(self)weakSelf = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectWifi:selectedWifi];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
