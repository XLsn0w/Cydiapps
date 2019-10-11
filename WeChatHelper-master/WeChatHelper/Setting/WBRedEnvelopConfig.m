//
//  WBRedEnvelopConfig.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBRedEnvelopConfig.h"

static NSString * const kDelaySecondsKey = @"kDelaySecondsKey";
static NSString * const kAutoReceiveRedEnvelopKey = @"kAutoReceiveRedEnvelopKey";
static NSString * const kRevokeEnablekey = @"kRevokeEnablekey";
static NSString * const kStarsCountkey = @"kStarsCountkey";
static NSString * const kCommentCountkey = @"kCommentCountkey";
static NSString * const kGameEnablekey = @"kGameEnablekey";

@interface WBRedEnvelopConfig ()

@end

@implementation WBRedEnvelopConfig

+ (instancetype)sharedConfig {
    static WBRedEnvelopConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [WBRedEnvelopConfig new];
    });
    return config;
}

- (instancetype)init {
    if (self = [super init]) {
        _delaySeconds = [[NSUserDefaults standardUserDefaults] integerForKey:kDelaySecondsKey];
        _autoReceiveEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kAutoReceiveRedEnvelopKey];
        _revokeEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kRevokeEnablekey];
        _starsCount = [[NSUserDefaults standardUserDefaults] integerForKey:kStarsCountkey];
        _commentCount = [[NSUserDefaults standardUserDefaults] integerForKey:kCommentCountkey];
        _gameEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kGameEnablekey];
    }
    return self;
}

- (void)setDelaySeconds:(NSInteger)delaySeconds {
    _delaySeconds = delaySeconds;
    
    [[NSUserDefaults standardUserDefaults] setInteger:delaySeconds forKey:kDelaySecondsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setAutoReceiveEnable:(BOOL)autoReceiveEnable {
    _autoReceiveEnable = autoReceiveEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:autoReceiveEnable forKey:kAutoReceiveRedEnvelopKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRevokeEnable:(BOOL)revokeEnable {
    _revokeEnable = revokeEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:revokeEnable forKey:kRevokeEnablekey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setStarsCount:(NSInteger)starsCount {
    _starsCount = starsCount;
    
    [[NSUserDefaults standardUserDefaults] setInteger:starsCount forKey:kStarsCountkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCommentCount:(NSInteger)commentCount {
    _commentCount = commentCount;
    
    [[NSUserDefaults standardUserDefaults] setInteger:commentCount forKey:kCommentCountkey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setGameEnable:(BOOL)gameEnable {
    _gameEnable = gameEnable;
    
    [[NSUserDefaults standardUserDefaults] setBool:gameEnable forKey:kGameEnablekey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
