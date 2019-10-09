//
//  KeychainHelper.m
//  KeychainIDFA
//
//  Created by Qixin on 14/12/18.
//  Copyright (c) 2014年 Qixin. All rights reserved.
//

#import "KeychainHelper.h"
#import <Security/Security.h>

@implementation KeychainHelper

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)(kSecClassGenericPassword),kSecClass,
            service, kSecAttrService,
            service, kSecAttrAccount,
            kSecAttrAccessibleAfterFirstUnlock,kSecAttrAccessible,nil];
}

+ (void)save:(NSString *)service data:(id)data
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data]
                      forKey:(__bridge id<NSCopying>)(kSecValueData)];
    SecItemAdd((__bridge CFDictionaryRef)(keychainQuery), NULL);
}

+ (id)load:(NSString *)service
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id<NSCopying>)(kSecReturnData)];
    [keychainQuery setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    
    CFTypeRef result = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, &result) == noErr)
    {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)result];
    }
    return ret;
}

+ (void)delete:(NSString *)service
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
}

@end
