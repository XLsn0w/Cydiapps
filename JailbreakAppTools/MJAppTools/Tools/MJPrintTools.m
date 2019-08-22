//
//  MJPrintTools.m
//  MJAppTools
//
//  Created by MJ Lee on 2018/1/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPrintTools.h"

const NSString *MJPrintColorDefault = @"\033[0m";

const NSString *MJPrintColorRed = @"\033[1;31m";
const NSString *MJPrintColorGreen = @"\033[1;32m";
const NSString *MJPrintColorBlue = @"\033[1;34m";
const NSString *MJPrintColorWhite = @"\033[1;37m";
const NSString *MJPrintColorBlack = @"\033[1;30m";
const NSString *MJPrintColorYellow = @"\033[1;33m";
const NSString *MJPrintColorCyan = @"\033[1;36m";
const NSString *MJPrintColorMagenta = @"\033[1;35m";

const NSString *MJPrintColorWarning = @"\033[1;33m";
const NSString *MJPrintColorError = @"\033[1;31m";
const NSString *MJPrintColorStrong = @"\033[1;32m";

#define MJBeginFormat \
if (!format) return; \
va_list args; \
va_start(args, format); \
format = [[NSString alloc] initWithFormat:format arguments:args];

#define MJEndFormat va_end(args);

@implementation MJPrintTools

+ (void)printError:(NSString *)format, ...
{
    MJBeginFormat;
    format = [@"Error: " stringByAppendingString:format];
    [self printColor:(NSString *)MJPrintColorError format:format];
}

+ (void)printWarning:(NSString *)format, ...
{
    MJBeginFormat;
    format = [@"Warning: " stringByAppendingString:format];
    [self printColor:(NSString *)MJPrintColorWarning format:format];
    MJEndFormat;
}

+ (void)printStrong:(NSString *)format, ...
{
    MJBeginFormat;
    [self printColor:(NSString *)MJPrintColorStrong format:format];
    MJEndFormat;
}

+ (void)print:(NSString *)format, ...
{
    MJBeginFormat;
    [self printColor:nil format:format];
    MJEndFormat;
}

+ (void)printColor:(NSString *)color format:(NSString *)format, ...
{
    MJBeginFormat;
    
    NSMutableString *printStr = [NSMutableString string];
    if (color && ![color isEqual:MJPrintColorDefault]) {
        [printStr appendString:color];
        [printStr appendString:format];
        [printStr appendString:(NSString *)MJPrintColorDefault];
    } else {
        [printStr appendString:(NSString *)MJPrintColorDefault];
        [printStr appendString:format];
    }
    printf("%s", printStr.UTF8String);
    
    MJEndFormat;
}

@end
