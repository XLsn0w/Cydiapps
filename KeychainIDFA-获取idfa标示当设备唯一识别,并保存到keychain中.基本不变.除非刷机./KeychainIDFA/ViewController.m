//
//  ViewController.m
//  KeychainIDFA
//
//  Created by Qixin on 14/12/18.
//  Copyright (c) 2014年 Qixin. All rights reserved.
//

#import "ViewController.h"
#import "KeychainIDFA.h"

//第一次:2d54d261-7bae-4014-8b81-3f9ff969b6e1
//第二次:2d54d261-7bae-4014-8b81-3f9ff969b6e1
//卸载app启动:2d54d261-7bae-4014-8b81-3f9ff969b6e1

//delete之后:2b8d8afc-7f87-4c9c-ac73-ec64a89fc1a8
//delete之后2次:2b8d8afc-7f87-4c9c-ac73-ec64a89fc1a8
//delete之后卸载:2b8d8afc-7f87-4c9c-ac73-ec64a89fc1a8

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[KeychainIDFA deleteIDFA];
    NSLog(@"%@",[KeychainIDFA IDFA]);
}

@end
