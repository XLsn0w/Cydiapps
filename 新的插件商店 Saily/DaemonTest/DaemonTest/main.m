//
//  main.m
//  DaemonTest
//
//  Created by Lakr Aream on 2019/7/26.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "../../Saily.Daemon/CommandLineMain.h"

int main(int argc, char * argv[]) {
    
    return command_line_main(argc, (const char **)argv);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
