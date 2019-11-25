//
//  WBWifiStore.h
//  DingTalkAssistant
//
//  Created by buginux on 2017/7/29.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBWifiModel;
@interface WBWifiStore : NSObject

+ (instancetype)sharedStore;

@property (nonatomic, strong) NSMutableArray *currentWifiList;
@property (nonatomic, strong) NSMutableArray *historyWifiList;

- (void)fetchCurrentWifi;
- (void)fetchHistoryWifi;
- (void)appendHistoryWifi:(WBWifiModel *)wifi;
- (void)saveHistoryWifi;

- (void)hookWifi:(WBWifiModel *)wifi;
- (WBWifiModel *)wifiHooked;

@end
