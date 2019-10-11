#import "xia0WeChat.h"
#import "WBSettingViewController.h"
#import <objc/objc-runtime.h>
#import "WBMultiSelectGroupsViewController.h"
#import "XEditViewController.h"

#define XLOG(log, ...)  NSLog(@"xia0:" log, ##__VA_ARGS__)

@interface WBSettingViewController () <MultiSelectGroupsViewControllerDelegate>

@property (nonatomic, strong) WCTableViewManager *tableViewInfo;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // 增加对iPhone X的屏幕适配
        CGRect winSize = [UIScreen mainScreen].bounds;
        if (winSize.size.height == 812) { // iPhone X 高为812
            winSize.size.height -= 88;
            winSize.origin.y = 88;
        }
        _tableViewInfo = [[objc_getClass("WCTableViewManager") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle];
    [self reloadTableData];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView setContentInset:UIEdgeInsetsMake(0,0,65,0)];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"积攒助手设置";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addZanSettingSection];
    [self addSupportSection];
    [self addAboutSection];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];

    [tableView reloadData];
}

#pragma mark - ZanSetting
- (void)addZanSettingSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"集赞功能设置:建议先在朋友圈详情页面刷新数据再回到朋友圈查看，每次重新打开微信会更新朋友联系人数量。bug反馈、建议可以去github发起issue。获取最新的版本，可以添加作者源：https://xia0z.github.io"];

    [sectionInfo addCell:[self createOpenFKZanCell]];
    BOOL isOpenFKZan = [[NSUserDefaults standardUserDefaults] boolForKey:@"kOpenFKZan"];
    if (isOpenFKZan)
    {
        [sectionInfo addCell:[self createFKZanCell]];
        [sectionInfo addCell:[self createFKCmtCell]];

        [sectionInfo addCell:[self createKeepOldSwitchCell]];
        [sectionInfo addCell:[self createRandomPerOpenCell]];
        [sectionInfo addCell:[self createNotFriendZanCell]];
        [sectionInfo addCell:[self createFriendZanRepeatCell]];

        [sectionInfo addCell:[self createMyCmtSwitchCell]];

        BOOL isOpenMyCmt = [[NSUserDefaults standardUserDefaults] boolForKey:@"kMoreCmtOpenMyCmt"];
        if (isOpenMyCmt)
        {
            [sectionInfo addCell:[self createMyCmtContentCell]];
        }
    }

    [self.tableViewInfo addSection:sectionInfo];
}


- (WCTableViewCellManager *)createOpenFKZanCell {

    BOOL isOpenFKZan = [[NSUserDefaults standardUserDefaults] boolForKey:@"kOpenFKZan"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingOpenFKZanSwitch:) target:self title:@"开启积攒插件功能" on:isOpenFKZan];

    return cellInfo;
}


- (WCTableViewCellManager *)createFKZanCell {
    NSInteger zanCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreZanID"];
    if (!zanCount)
    {
        zanCount = 0;
    }

     return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMoreZan) target:self title:@"集攒数量设置" rightValue:[@(zanCount) stringValue] WithDisclosureIndicator:0];
}

- (void)settingMoreZan{
    int frienfCount = 0;
    NSArray* friendArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"kFriendListCache"];
    XLOG(@"settingMoreZan frienfCount:%d", [friendArr count]);
    if (friendArr)
    {
        frienfCount = [friendArr count];
    }

    NSInteger zanCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreZanID"];
    [self alertControllerWithTitle:@"积攒数量设置"
                           message:@"设置需要的赞个数\n数量最多为朋友总数量"
                           content:[NSString stringWithFormat:@"%ld", (long)zanCount]
                       placeholder:[NSString stringWithFormat:@"当前数量:%ld", (long)zanCount]
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[NSUserDefaults standardUserDefaults] setInteger:textField.text.integerValue forKey:@"kMoreZanID"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   [self reloadTableData];
                               }];
}

- (WCTableViewCellManager *)createFKCmtCell {
    NSInteger cmtCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreCmtID"];
    if (!cmtCount)
    {
        cmtCount = 0;
    }

     return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMoreCmt) target:self title:@"评论数量设置" rightValue:[@(cmtCount) stringValue] WithDisclosureIndicator:0];
}

- (void)settingMoreCmt{
    int frienfCount = 0;
    NSArray* friendArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"kFriendListCache"];
    XLOG(@"settingMoreCmt frienfCount:%d", [friendArr count]);
    if (friendArr)
    {
        frienfCount = [friendArr count];
    }

    NSInteger cmtCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreCmtID"];
    [self alertControllerWithTitle:@"评论数量设置"
                           message:@"设置需要的评论个数\n数量最多为朋友总数量"
                           content:[NSString stringWithFormat:@"%ld", (long)cmtCount]
                       placeholder:[NSString stringWithFormat:@"当前数量:%ld", (long)cmtCount]
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[NSUserDefaults standardUserDefaults] setInteger:textField.text.integerValue forKey:@"kMoreCmtID"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   [self reloadTableData];
                               }];
}

- (WCTableViewCellManager *)createKeepOldSwitchCell {

    BOOL isKeepOld = [[NSUserDefaults standardUserDefaults] boolForKey:@"kDatatKeepOld"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingKeepOldSwitch:) target:self title:@"开启保留原始赞/评论" on:isKeepOld];

    return cellInfo;
}

- (WCTableViewCellManager *)createRandomPerOpenCell {

    BOOL randomPerOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"kRandomPerOpen"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingRandomPerOpenSwitch:) target:self title:@"开启每次赞/评论数据随机刷新" on:randomPerOpen];

    return cellInfo;
}

- (WCTableViewCellManager *)createNotFriendZanCell {

    BOOL notFriendZan = [[NSUserDefaults standardUserDefaults] boolForKey:@"kNotFriendZan"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingNotFriendZanSwitch:) target:self title:@"开启非好友点赞/评论" on:notFriendZan];

    return cellInfo;
}

- (WCTableViewCellManager *)createFriendZanRepeatCell {

    BOOL friendZanRepeat = [[NSUserDefaults standardUserDefaults] boolForKey:@"kFriendZanRepeat"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingFriendZanRepeatSwitch:) target:self title:@"开启点赞好友可以重复" on:friendZanRepeat];

    return cellInfo;
}


- (WCTableViewCellManager *)createMyCmtSwitchCell {

    BOOL isOpenMyCmt = [[NSUserDefaults standardUserDefaults] boolForKey:@"kMoreCmtOpenMyCmt"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingMyCmtSwitch:) target:self title:@"开启自定义评论" on:isOpenMyCmt];

    return cellInfo;
}

- (WCTableViewCellManager *)createMyCmtContentCell {
    NSString *myCmtContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"kMoreCmtMyCmtContent"];
    myCmtContent = myCmtContent.length == 0 ? @"请填写" : myCmtContent;

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMyCmtContent) target:self title:@"自定义评论内容" rightValue:myCmtContent WithDisclosureIndicator:1];

    return cellInfo;
}

- (void)settingOpenFKZanSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kOpenFKZan"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}

- (void)settingKeepOldSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kDatatKeepOld"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}


- (void)settingNotFriendZanSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kFriendListCache"];
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kNotFriendZan"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}

- (void)settingRandomPerOpenSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kRandomPerOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}

- (void)settingFriendZanRepeatSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kFriendZanRepeat"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}

- (void)settingMyCmtSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kMoreCmtOpenMyCmt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}

- (void)settingMyCmtContent {
    XEditViewController *editVC = [[XEditViewController alloc] init];
    editVC.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kMoreCmtMyCmtContent"];
    [editVC setEndEditing:^(NSString *text) {
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"kMoreCmtMyCmtContent"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reloadTableData];
    }];
    editVC.title = @"请输入自定义评论内容";
    editVC.placeholder = @"开启时会从中随机生成(一行为一条评论)";
    [self.navigationController PushViewController:editVC animated:YES];
}

#pragma mark - About
- (void)addAboutSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"关于我/项目" Footer:@"\nDEVELOPED BY X1A0@2019\n\n"];
    
    [sectionInfo addCell:[self createAboutmeCell]];
    [sectionInfo addCell:[self createGithubCell]];
    [sectionInfo addCell:[self createBlogCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (WCTableViewCellManager *)createAboutmeCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showAboutme) target:self title:@"关于我" rightValue: @"xia0" WithDisclosureIndicator:1];
}

- (WCTableViewCellManager *)createGithubCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showGithub) target:self title:@"项目Github" rightValue: @"🌟star" WithDisclosureIndicator:1];
}

- (WCTableViewCellManager *)createBlogCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showBlog) target:self title:@"项目分析"];
}

- (void)showAboutme {
    NSURL *gitHubUrl = [NSURL URLWithString:@"http://4ch12dy.site/aboutme/"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showGithub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://github.com/4ch12dy/fkwechatzan"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showBlog {
    NSURL *blogUrl = [NSURL URLWithString:@"http://4ch12dy.site/2019/07/22/fkwechatLike/fkwechatLike/"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:blogUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

#pragma mark - Support
- (void)addSupportSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"若有帮助，可以打赏支持作者"];
    
    [sectionInfo addCell:[self createWeChatPayingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (WCTableViewCellManager *)createWeChatPayingCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"支持作者😈" WithDisclosureIndicator:1];
}

- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:31];
    scanQRCodeLogic.fromScene = 1;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:31];

    NSString *rewardStr = @"m0Ms67nN$+P*ZKLtExYpfe";
    NSData *rewardData = [rewardStr dataUsingEncoding:4];  
    [qrCodeScanner notifyResult:rewardStr type:@"WX_CODE" version:0 rawData:rewardData];
}

#pragma mark - MultiSelectGroupsViewControllerDelegate
- (void)onMultiSelectGroupCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onMultiSelectGroupReturn:(NSArray *)arg1 {
    
    [self reloadTableData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertControllerWithTitle:(NSString *)title content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:nil content:content placeholder:placeholder blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:message content:content placeholder:placeholder keyboardType:UIKeyboardTypeDefault blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType blk:(void (^)(UITextField *))blk  {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (blk) {
                                                        blk(alert.textFields.firstObject);
                                                    }
                                                }]];

        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeholder;
            textField.text = content;
            textField.keyboardType = keyboardType;
        }];

        alert;
    });

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
