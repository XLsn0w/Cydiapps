//
//  LLBaseTableViewController.h
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

#import "LLBaseComponentViewController.h"
#import "LLBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLBaseTableViewController : LLBaseComponentViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

/**
 * Whether use searchBar. Default is NO.
 */
@property (nonatomic, assign) BOOL isSearchEnable;

/**
 * Whether selectable. Default is NO.
 */
@property (nonatomic, assign) BOOL isSelectEnable;

/**
 * Whether shareable. Default is NO.
 */
@property (nonatomic, assign) BOOL isShareEnable;

/**
 * Whether deleteable. Default is NO.
 */
@property (nonatomic, assign) BOOL isDeleteEnable;

/**
 * The default tableView in view controller.
 */
@property (nonatomic, strong, readonly) UITableView *tableView;

/**
 * Original data array.
 */
@property (nonatomic, strong, readonly) NSMutableArray *dataArray;

/**
 * Filter data array.
 */
@property (nonatomic, strong, readonly) NSMutableArray *searchDataArray;

/**
 * Automatic data array dealed by search or filter.
 */
@property (nonatomic, strong, readonly) NSMutableArray *datas;

/**
 * Header view use to show searchBar and filter view.
 */
@property (nonatomic, strong, nullable, readonly) UIView *headerView;

/**
 * The searchBar in view controller.
 */
@property (nonatomic, strong, nullable, readonly) UISearchBar *searchBar;

/**
 * Select all item in toolbar.
 */
@property (nonatomic, strong, nullable, readonly) UIBarButtonItem *selectAllItem;

/**
 * Share item in toolbar.
 */
@property (nonatomic, strong, nullable, readonly) UIBarButtonItem *shareItem;

/**
 * Delete item in toolbar.
 */
@property (nonatomic, strong, nullable, readonly) UIBarButtonItem *deleteItem;

/**
 * Initial method.
 */
- (instancetype _Nonnull)initWithStyle:(UITableViewStyle)style;
- (instancetype _Nonnull)init;// Default is UITableViewStyleGrouped.

#pragma mark - Rewrite
/**
* Left item action.
*/
- (void)leftItemClick:(UIButton *)sender;

/**
 * Right item action. Must call super method.
 */
- (void)rightItemClick:(UIButton *)sender;

/**
 * Share files action. Must call super method.
 */
- (void)shareFilesWithIndexPaths:(NSArray *)indexPaths;

/**
 * Delete files action. Must call super method.
 */
- (void)deleteFilesWithIndexPaths:(NSArray *)indexPaths;

/**
 * Rewrite method to control whether is searching. Must call super method.
 */
- (BOOL)isSearching;

@end

NS_ASSUME_NONNULL_END
