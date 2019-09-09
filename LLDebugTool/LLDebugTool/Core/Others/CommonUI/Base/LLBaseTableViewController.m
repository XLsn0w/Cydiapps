//
//  LLBaseViewController.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLBaseTableViewController.h"
#import "LLMacros.h"
#import "LLConfig.h"
#import "LLImageNameConfig.h"
#import "LLFactory.h"
#import "LLThemeManager.h"

static NSString *const kEmptyCellID = @"emptyCellID";

@interface LLBaseTableViewController ()

@property (nonatomic, assign) UITableViewStyle style;

@property (nonatomic, copy) NSString *selectAllString;

@property (nonatomic, copy) NSString *cancelAllString;

@end

@implementation LLBaseTableViewController

- (instancetype)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super init]) {
        _style = style;
        _dataArray = [[NSMutableArray alloc] init];
        _searchDataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    if (self.isSearchEnable) {
        [self initSearchEnableFunction];
    }
    if (self.isSelectEnable) {
        [self initSelectEnableFunction];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isSearchEnable) {
        if (self.searchBar.isFirstResponder) {
            [self.searchBar resignFirstResponder];
        }
    }
    if (self.isSelectEnable) {
        [self endEditing];
    }
}

#pragma mark - Override
- (void)rightItemClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.tableView setEditing:sender.isSelected animated:YES];
    [self.navigationController setToolbarHidden:!sender.isSelected animated:YES];
    if (self.isSelectEnable) {
        if (sender.isSelected) {
            self.selectAllItem.title = self.selectAllString;
            self.selectAllItem.enabled = (self.datas.count != 0);
            self.shareItem.enabled = NO;
            self.deleteItem.enabled = NO;
        }
    }
}

- (void)shareFilesWithIndexPaths:(NSArray *)indexPaths {
    
}

- (void)deleteFilesWithIndexPaths:(NSArray *)indexPaths {
    [self endEditing];
}

- (BOOL)isSearching {
    return self.searchBar.text.length;
}

#pragma mark - Primary
- (void)initTableView {
    _tableView = [LLFactory getTableView:self.view frame:self.view.bounds delegate:self style:_style];
//    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [LLThemeManager shared].backgroundColor;
    [self.tableView setSeparatorColor:[LLThemeManager shared].primaryColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }
}

- (void)initSearchEnableFunction {
    _searchBar = [[UISearchBar alloc] init];
    self.searchBar.barTintColor = [LLThemeManager shared].backgroundColor;
    self.searchBar.tintColor = [LLThemeManager shared].primaryColor;
    self.searchBar.delegate = self;
    self.searchBar.enablesReturnKeyAutomatically = NO;
    [self.searchBar sizeToFit];

    _headerView = [LLFactory getBackgroundView:self.view frame:CGRectMake(0, LL_NAVIGATION_HEIGHT, LL_SCREEN_WIDTH, self.searchBar.frame.size.height)];
    [self.headerView addSubview:self.searchBar];
}

- (void)initSelectEnableFunction {
    self.selectAllString = @"Select All";
    self.cancelAllString = @"Cancel All";
    
    // Navigation bar item
    [self initNavigationItemWithTitle:nil imageName:kEditImageName isLeft:NO];
    [self.rightNavigationButton setImage:[[UIImage LL_imageNamed:kDoneImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    // ToolBar
    _selectAllItem = [[UIBarButtonItem alloc] initWithTitle:self.selectAllString style:UIBarButtonItemStylePlain target:self action:@selector(selectAllItemClick:)];
    self.selectAllItem.tintColor = [LLThemeManager shared].primaryColor;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    _shareItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareItemClick:)];
    self.shareItem.tintColor = [LLThemeManager shared].primaryColor;
    self.shareItem.enabled = NO;
    
    _deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteItemClick:)];
    self.deleteItem.tintColor = [LLThemeManager shared].primaryColor;
    self.deleteItem.enabled = NO;
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:self.selectAllItem, spaceItem, nil];
    if (self.isShareEnable) {
        [items addObject:self.shareItem];
    }
    if (self.isDeleteEnable) {
        [items addObject:self.deleteItem];
    }
    [self setToolbarItems:items];
    
    self.navigationController.toolbar.barTintColor = [LLThemeManager shared].backgroundColor;
}

- (void)leftItemClick:(UIButton *)sender {
    if (self.isSearchEnable) {
        if (self.searchBar.isFirstResponder) {
            [self.searchBar resignFirstResponder];
        }
    }
    [super leftItemClick:sender];
}

- (void)selectAllItemClick:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:self.selectAllString]) {
        sender.title = self.cancelAllString;
        [self updateTableViewCellSelectedStyle:YES];
        self.shareItem.enabled = YES;
        self.deleteItem.enabled = YES;
    } else {
        sender.title = self.selectAllString;
        [self updateTableViewCellSelectedStyle:NO];
        self.shareItem.enabled = NO;
        self.deleteItem.enabled = NO;
    }
}

- (void)updateTableViewCellSelectedStyle:(BOOL)selected {
    NSInteger row = [self tableView:self.tableView numberOfRowsInSection:0];
    for (int j = 0; j < row; j++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:0];
        if (selected) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

- (void)shareItemClick:(UIBarButtonItem *)sender {
    NSArray *indexPaths = self.tableView.indexPathsForSelectedRows;
    if (indexPaths.count) {
        [self shareFilesWithIndexPaths:indexPaths];
    }
}

- (void)deleteItemClick:(UIBarButtonItem *)sender {
    NSArray *indexPaths = self.tableView.indexPathsForSelectedRows;
    [self showDeleteAlertWithIndexPaths:indexPaths];
}

- (void)showDeleteAlertWithIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count) {
        [self showAlertControllerWithMessage:[NSString stringWithFormat:@"Sure to delete these %ld items?", (long)indexPaths.count] handler:^(NSInteger action) {
            if (action == 1) {
                [self deleteFilesWithIndexPaths:indexPaths];
            }
        }];
    }
}

- (void)endEditing {
    if (self.tableView.isEditing) {
        [self rightItemClick:self.navigationItem.rightBarButtonItem.customView];
    }
}

- (NSMutableArray *)datas {
    if (self.isSearchEnable && [self isSearching]) {
        return self.searchDataArray;
    }
    return self.dataArray;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEmptyCellID];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isSearchEnable) {
        return self.searchBar.frame.size.height;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        if (self.tableView.indexPathsForSelectedRows.count == self.dataArray.count) {
            if ([self.selectAllItem.title isEqualToString:self.selectAllString]) {
                self.selectAllItem.title = self.cancelAllString;
            }
        }
        self.shareItem.enabled = YES;
        self.deleteItem.enabled = YES;
    } else {
        if (self.isSelectEnable) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        if (![self.selectAllItem.title isEqualToString:self.selectAllString]) {
            self.selectAllItem.title = self.selectAllString;
        }
        if (self.tableView.indexPathsForSelectedRows.count == 0) {
            self.shareItem.enabled = NO;
            self.deleteItem.enabled = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isDeleteEnable) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self showDeleteAlertWithIndexPaths:@[indexPath]];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isDeleteEnable) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isSearchEnable && self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([self.selectAllItem.title isEqualToString:self.cancelAllString]) {
        self.selectAllItem.title = self.selectAllString;
    }
    if (self.isDeleteEnable && self.deleteItem.isEnabled) {
        self.deleteItem.enabled = NO;
        self.shareItem.enabled = NO;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self searchBar:searchBar textDidChange:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

@end
