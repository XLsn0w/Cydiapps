//
//  main.m
//  MJAppTools-iOS
//
//  Created by MJ Lee on 2018/1/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJAppTools.h"
#import "MJMachO.h"
#import <UIKit/UIKit.h>
#import "MJPrintTools.h"

#define MJEncryptedString @"加壳"
#define MJDecryptedString @"未加壳"

#define MJPrintNewLine printf("\n")
#define MJPrintDivider(n) \
NSMutableString *dividerString = [NSMutableString string]; \
for (int i = 0; i<(n); i++) { \
[dividerString appendString:@"-"]; \
} \
[MJPrintTools print:dividerString];

static NSString *MJPrintColorCount;
static NSString *MJPrintColorNo;
static NSString *MJPrintColorCrypt;
static NSString *MJPrintColorName;
static NSString *MJPrintColorPath;
static NSString *MJPrintColorId;
static NSString *MJPrintColorArch;
static NSString *MJPrintColorTip;

void print_usage(void);
void list_machO(MJMachO *machO);
void list_app(MJApp *app, int index);
void list_apps(MJListAppsType type, NSString *regex);
void init_colors(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        init_colors();
        
        BOOL gt_ios8 = ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending);
        if (!gt_ios8) {
            [MJPrintTools printError:@"MJAppTools目前不支持iOS8以下系统\n"];
            return 0;
        }
    
        if (argc == 1) { // 参数不够
            print_usage();
            return 0;
        }
        
        const char *firstArg = argv[1];
        if (firstArg[0] == '-' && firstArg[1] == 'l') {
            NSString *regex = nil;
            if (argc > 2) {
                regex = [NSString stringWithUTF8String:argv[2]];
            }
            
            if (strcmp(firstArg, "-le") == 0) {
                list_apps(MJListAppsTypeUserEncrypted, regex);
            } else if (strcmp(firstArg, "-ld") == 0) {
                list_apps(MJListAppsTypeUserDecrypted, regex);
            } else if (strcmp(firstArg, "-ls") == 0) {
                list_apps(MJListAppsTypeSystem, regex);
            } else {
                list_apps(MJListAppsTypeUser, regex);
            }
        } else {
            print_usage();
        }
    }
    return 0;
}

void init_colors()
{
    MJPrintColorCount = MJPrintColorMagenta;
    MJPrintColorNo = MJPrintColorDefault;
    MJPrintColorName = MJPrintColorRed;
    MJPrintColorPath = MJPrintColorBlue;
    MJPrintColorCrypt = MJPrintColorMagenta;
    MJPrintColorId = MJPrintColorCyan;
    MJPrintColorArch = MJPrintColorGreen;
    MJPrintColorTip = MJPrintColorCyan;
}

void print_usage()
{
    [MJPrintTools printColor:MJPrintColorTip format:@"  -l  <regex>"];
    [MJPrintTools print:@"\t列出用户安装的应用\n"];
    
    [MJPrintTools printColor:MJPrintColorTip format:@"  -le <regex>"];
    [MJPrintTools print:@"\t列出用户安装的"];
    [MJPrintTools printColor:MJPrintColorCrypt format:MJEncryptedString];
    [MJPrintTools print:@"应用\n"];
    
    [MJPrintTools printColor:MJPrintColorTip format:@"  -ld <regex>"];
    [MJPrintTools print:@"\t列出用户安装的"];
    [MJPrintTools printColor:MJPrintColorCrypt format:MJDecryptedString];
    [MJPrintTools print:@"应用\n"];
    
    [MJPrintTools printColor:MJPrintColorTip format:@"  -ls <regex>"];
    [MJPrintTools print:@"\t列出"];
    [MJPrintTools printColor:MJPrintColorCrypt format:@"系统"];
    [MJPrintTools print:@"的应用\n"];
}

void list_app(MJApp *app, int index)
{
    [MJPrintTools print:@"# "];
    [MJPrintTools printColor:MJPrintColorNo format:@"%02d ", index +1];
    [MJPrintTools print:@"【"];
    [MJPrintTools printColor:MJPrintColorName format:@"%@", app.displayName];
    [MJPrintTools print:@"】 "];
    [MJPrintTools print:@"<"];
    [MJPrintTools printColor:MJPrintColorId format:@"%@", app.bundleIdentifier];
    [MJPrintTools print:@">"];
    
    MJPrintNewLine;
    [MJPrintTools print:@"  "];
    [MJPrintTools printColor:MJPrintColorPath format:app.bundlePath];
    
    if (app.dataPath.length) {
        MJPrintNewLine;
        [MJPrintTools print:@"  "];
        [MJPrintTools printColor:MJPrintColorPath format:app.dataPath];
    }
    
    if (app.executable.isFat) {
        MJPrintNewLine;
        [MJPrintTools print:@"  "];
        [MJPrintTools printColor:MJPrintColorArch format:@"Universal binary"];
        for (MJMachO *machO in app.executable.machOs) {
            MJPrintNewLine;
            printf("      ");
            list_machO(machO);
        }
    } else {
        MJPrintNewLine;
        [MJPrintTools print:@"  "];
        list_machO(app.executable);
    }
}

void list_apps(MJListAppsType type, NSString *regex)
{
    [MJAppTools listUserAppsWithType:type regex:regex operation:^(NSArray *apps) {
        [MJPrintTools print:@"# 一共"];
        [MJPrintTools printColor:MJPrintColorCount format:@"%zd", apps.count];
        [MJPrintTools print:@"个"];
        if (type == MJListAppsTypeUserDecrypted) {
            [MJPrintTools printColor:MJPrintColorCrypt format:MJDecryptedString];
        } else if (type == MJListAppsTypeUserEncrypted) {
            [MJPrintTools printColor:MJPrintColorCrypt format:MJEncryptedString];
        } else if (type == MJListAppsTypeSystem) {
            [MJPrintTools printColor:MJPrintColorCrypt format:@"系统"];
        }
        [MJPrintTools print:@"应用"];
        
        for (int i = 0; i < apps.count; i++) {
            MJPrintNewLine;
            MJPrintDivider(5);
            MJPrintNewLine;
            list_app(apps[i], i);
        }
        MJPrintNewLine;
    }];
}

void list_machO(MJMachO *machO)
{
    [MJPrintTools printColor:MJPrintColorArch format:machO.architecture];
    if (machO.isEncrypted) {
        [MJPrintTools print:@" "];
        [MJPrintTools printColor:MJPrintColorCrypt format:MJEncryptedString];
    }
}
