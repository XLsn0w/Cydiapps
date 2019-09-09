//
//  TestCrashViewController.m
//  LLDebugToolDemo
//
//  Created by admin10000 on 2018/8/29.
//  Copyright © 2018年 li. All rights reserved.
//

#import "TestCrashViewController.h"
#import "LLDebugTool.h"

@interface TestCrashViewController ()

@end

@implementation TestCrashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"test.crash", nil);
    [self initNoteView];
}

- (void)initNoteView {
    UIView *header = [[UIView alloc] init];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.text = NSLocalizedString(@"crash.tip", nil);
    CGSize size = [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, CGFLOAT_MAX)];
    label.frame = CGRectMake(10, 10, size.width, size.height);
    header.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, size.height + 20);
    [header addSubview:label];
    
    UIView *footer = [[UIView alloc] init];
    //1570 × 1050
    CGFloat imageViewWidth = [UIScreen mainScreen].bounds.size.width - 20;
    CGFloat imageViewHeight = imageViewWidth * 1050 / 1570;
    CGFloat tipHeight = 30;
    UIImageView *imageView1 = [[UIImageView alloc] init];
    imageView1.image = [UIImage imageNamed:@"crash-1.jpg"];
    imageView1.frame = CGRectMake(10, 10, imageViewWidth, imageViewHeight);
    [footer addSubview:imageView1];
    
    UILabel *tip1 = [[UILabel alloc] init];
    tip1.textAlignment = NSTextAlignmentCenter;
    tip1.font = [UIFont systemFontOfSize:14];
    tip1.text = @"Tip 1";
    tip1.frame = CGRectMake(0, 10 + imageViewHeight, [UIScreen mainScreen].bounds.size.width, tipHeight);
    [footer addSubview:tip1];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
    imageView2.image = [UIImage imageNamed:@"crash-2.jpg"];
    imageView2.frame = CGRectMake(10, 10 + imageViewHeight + tipHeight + 10, imageViewWidth, imageViewHeight);
    [footer addSubview:imageView2];
    
    UILabel *tip2 = [[UILabel alloc] init];
    tip2.textAlignment = NSTextAlignmentCenter;
    tip2.font = [UIFont systemFontOfSize:14];
    tip2.text = @"Tip 2";
    tip2.frame = CGRectMake(0, 10 + imageViewHeight + tipHeight + 10 + imageViewHeight, [UIScreen mainScreen].bounds.size.width, tipHeight);
    [footer addSubview:tip2];

    footer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 10 + imageViewHeight + tipHeight + 10 + imageViewHeight + tipHeight + 10);
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = footer;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"try.array.crash", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"crash.info", nil);
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"try.pointer.crash", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"crash.info", nil);
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"try.signal", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"signal.info", nil);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self testArrayOutRangeCrash];
    } else if (indexPath.row == 1) {
        [self testPointErrorCrash];
    } else if (indexPath.row == 2) {
        [self testSignalCrash];
    }
}

#pragma mark - Actions
- (void)testArrayOutRangeCrash {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"openCrash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    sleep(1);
    NSArray *array = @[@"a",@"b"];
    __unused NSString *str = array[3];
}

- (void)testPointErrorCrash {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"openCrash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    sleep(1);
    NSArray *a = (NSArray *)@"dssdf";
    __unused NSString *b = [a firstObject];
}

- (void)testSignalCrash {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"openCrash"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    kill(0, SIGTRAP);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[LLDebugTool sharedTool] executeAction:LLDebugToolActionCrash];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"openCrash"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}

@end
