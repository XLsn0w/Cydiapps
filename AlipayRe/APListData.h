//
//  APListData.h
//  GameTodayNews
//
//  Created by cardlan_yuhuajun on 2017/11/14.
//  Copyright © 2017年 hua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APListData : NSObject

+(id)sharedInstance;
@property(nonatomic,strong)id jsBridge;
@property(nonatomic,strong)id topFriends;
@property(atomic,strong)NSMutableDictionary *topBubblesDic;

@end
