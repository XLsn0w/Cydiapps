//
//  MJPrintTools.h
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *MJPrintColorDefault;

extern NSString *MJPrintColorRed;
extern NSString *MJPrintColorGreen;
extern NSString *MJPrintColorBlue;
extern NSString *MJPrintColorWhite;
extern NSString *MJPrintColorBlack;
extern NSString *MJPrintColorYellow;
extern NSString *MJPrintColorCyan;
extern NSString *MJPrintColorMagenta;

extern NSString *MJPrintColorWarning;
extern NSString *MJPrintColorError;
extern NSString *MJPrintColorStrong;

@interface MJPrintTools : NSObject

+ (void)print:(NSString *)format, ...;
+ (void)printError:(NSString *)format, ...;
+ (void)printWarning:(NSString *)format, ...;
+ (void)printStrong:(NSString *)format, ...;
+ (void)printColor:(NSString *)color format:(NSString *)format, ...;

@end
