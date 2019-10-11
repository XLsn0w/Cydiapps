#import "xia0WeChat.h"
#import "WBSettingViewController.h"

%hook NewSettingViewController

- (void)reloadTableData {
	%orig;

	MMTableViewInfo *tableViewInfo = MSHookIvar<id>(self, "m_tableViewMgr");

	WCTableViewSectionManager *sectionInfo = [%c(WCTableViewSectionManager) defaultSection];

	WCTableViewCellManager *settingCell = [%c(WCTableViewCellManager) normalCellForSel:@selector(setting) target:self title:@"积赞助手 V0.0.3"];
	[sectionInfo addCell:settingCell];

	[tableViewInfo insertSection:sectionInfo At:0];

	MMTableView *tableView = [tableViewInfo getTableView];
	[tableView reloadData];
}

%new
- (void)setting {
	WBSettingViewController *settingViewController = [WBSettingViewController new];
	[self.navigationController PushViewController:settingViewController animated:YES];
}

%end