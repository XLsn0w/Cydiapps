//
//  APListData.m
//  GameTodayNews
//
//  Created by cardlan_yuhuajun on 2017/11/14.
//  Copyright © 2017年 hua. All rights reserved.
//

#import "APListData.h"

@implementation APListData
@synthesize jsBridge;
@synthesize topFriends;
@synthesize topBubblesDic;

static APListData *apList=nil;
+(id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apList=[[self alloc]init];
        
    });
    return apList;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apList = [super allocWithZone:zone];
    });
    return apList;
}

/*-(NSMutableDictionary*)topBubblesDic
{
    if(!_topBubblesDic){
        _topBubblesDic=[NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _topBubblesDic;
}

-(void)setTopBubblesDic:(NSMutableDictionary *)topBubblesDic{
    
    _topBubblesDic=topBubblesDic;
    if(_topBubblesDic!=topBubblesDic)
    {
        [_topBubblesDic release];
        _topBubblesDic=[topBubblesDic retain];
    }
    
}*/
@end
