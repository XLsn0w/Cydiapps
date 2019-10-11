//
//  WBSettingViewController.m
//  WeChatRedEnvelop
//
//  Created by 杨志超 on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WBSettingViewController.h"
#import "WBRedEnvelopConfig.h"

@interface WBSettingViewController ()

@property (nonatomic, strong) WCTableViewManager *tableViewMgr;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CGRect rect = [UIScreen mainScreen].bounds;
        rect.size.height -= 64;
        _tableViewMgr = [[objc_getClass("WCTableViewManager") alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle];
    [self reloadTableData];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    MMTableView *tableView = [self.tableViewMgr getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"微信助手";
}

- (void)reloadTableData {
    [self.tableViewMgr clearAllSection];
    
    [self addRedEnvelopSection];
    [self addStarsSection];
    [self addGameSection];
    [self addSupportSection];
    
    MMTableView *tableView = [self.tableViewMgr getTableView];
    [tableView reloadData];
}

#pragma mark - 抢红包
- (void)addRedEnvelopSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];

    [sectionInfo addCell:[self createRedEnvelopSwitchCell]];
    [sectionInfo addCell:[self createDelaySettingCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createRedEnvelopSwitchCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(switchRedEnvelop:) target:self title:@"自动抢红包" on:[WBRedEnvelopConfig sharedConfig].autoReceiveEnable];
}

- (WCTableViewCellManager *)createDelaySettingCell {
    NSInteger delaySeconds = [WBRedEnvelopConfig sharedConfig].delaySeconds;
    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
    
    WCTableViewCellManager *cellInfo = nil;
    if ([WBRedEnvelopConfig sharedConfig].autoReceiveEnable) {
        cellInfo = [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue:delayString WithDisclosureIndicator:1];
    } else {
        cellInfo = [objc_getClass("WCTableViewNormalCellManager") normalCellForTitle:@"延迟抢红包" rightValue: @"抢红包已关闭"];
    }
    return cellInfo;
}

- (void)switchRedEnvelop:(UISwitch *)envelopSwitch {
    [WBRedEnvelopConfig sharedConfig].autoReceiveEnable = envelopSwitch.on;
    
    [self reloadTableData];
}

- (void)settingDelay {
    [self alertControllerWithTitle:@"延迟抢红包(秒)"
                           message:nil
                           content:nil
                       placeholder:@"延迟时长(秒)"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [WBRedEnvelopConfig sharedConfig].delaySeconds = textField.text.integerValue;
                                   [self reloadTableData];
                               }];
}

#pragma mark - 其他功能
- (void)addSupportSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];

    [sectionInfo addCell:[self createAbortRemokeMessageCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewSectionManager *)createAbortRemokeMessageCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingMessageRevoke:) target:self title:@"消息防撤回" on:[WBRedEnvelopConfig sharedConfig].revokeEnable];
}

- (void)settingMessageRevoke:(UISwitch *)revokeSwitch {
    [WBRedEnvelopConfig sharedConfig].revokeEnable = revokeSwitch.on;
}

#pragma mark - 点赞
- (void)addStarsSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];

    [sectionInfo addCell:[self createStarCell]];
    [sectionInfo addCell:[self createCommentCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}
    
- (WCTableViewCellManager *)createStarCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMoreStar) target:self title:@"集攒数量" rightValue:[@([WBRedEnvelopConfig sharedConfig].starsCount) stringValue] WithDisclosureIndicator:1];
}
    
- (void)settingMoreStar {
    [self alertControllerWithTitle:@"集赞数量"
                           message:@"设置需要增加的赞数（原始赞保留）"
                           content:[NSString stringWithFormat:@"%ld", (long)[WBRedEnvelopConfig sharedConfig].starsCount]
                       placeholder:@"请输入需要增加的赞数"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [WBRedEnvelopConfig sharedConfig].starsCount = textField.text.integerValue;
                                   [self reloadTableData];
                               }];
}
    
- (WCTableViewCellManager *)createCommentCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMoreCmt) target:self title:@"评论数量" rightValue:[@([WBRedEnvelopConfig sharedConfig].commentCount) stringValue] WithDisclosureIndicator:1];
}
    
- (void)settingMoreCmt{
    [self alertControllerWithTitle:@"评论数量"
                           message:@"设置需要增加的评论数（原始赞保留）"
                           content:[NSString stringWithFormat:@"%ld", (long)[WBRedEnvelopConfig sharedConfig].commentCount]
                       placeholder:@"请输入需要增加的评论数"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [WBRedEnvelopConfig sharedConfig].commentCount = textField.text.integerValue;
                                   [self reloadTableData];
                               }];
}

#pragma mark -- 猜拳 筛子
- (void)addGameSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoDefaut];
    
    [sectionInfo addCell:[self createGameSwitchCell]];
    
    [self.tableViewMgr addSection:sectionInfo];
}

- (WCTableViewCellManager *)createGameSwitchCell {
    return [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(switchGame:) target:self title:@"猜拳按钮" on:[WBRedEnvelopConfig sharedConfig].gameEnable];
}

- (void)switchGame:(UISwitch *)envelopSwitch {
    [WBRedEnvelopConfig sharedConfig].gameEnable = envelopSwitch.on;
    
    [self reloadTableData];
}
@end
