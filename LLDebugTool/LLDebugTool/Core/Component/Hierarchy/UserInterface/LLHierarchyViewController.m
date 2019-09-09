//
//  LLHierarchyViewController.m
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

#import "LLHierarchyViewController.h"
#import "LLHierarchyCell.h"
#import "LLConfig.h"
#import "LLHierarchyHelper.h"
#import "LLMacros.h"
#import "LLThemeManager.h"

static NSString *const kHierarchyCellID = @"HierarchyCellID";

@interface LLHierarchyViewController () <LLHierarchyCellDelegate>

@property (nonatomic, strong) LLHierarchyModel *model;

@property (nonatomic, strong, nullable) LLHierarchyModel *selectModel;

@property (nonatomic, strong) UISegmentedControl *filterView;

@end

@implementation LLHierarchyViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isSearchEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

#pragma mark - Primary
- (void)initial {
    // TableView
    self.filterView.frame = CGRectMake(8, self.searchBar.frame.size.height, LL_SCREEN_WIDTH - 8 * 2, 30);
    [self.headerView addSubview:self.filterView];
    self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.frame.size.height + self.filterView.frame.size.height);
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"LLHierarchyCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kHierarchyCellID];    
}

- (void)loadData {
    [self updateModel];
    [self reloadData];
//    [self scrollToSelectView];
}

- (void)updateModel {
    self.model = [LLHierarchyHelper shared].hierarchyInApplication;
    self.navigationItem.title = @"View Hierarchy";
    if (self.selectView) {
        self.filterView.selectedSegmentIndex = 1;
    } else {
        self.filterView.selectedSegmentIndex = 0;
    }
}

- (void)reloadData {
    [self.dataArray removeAllObjects];
    if (self.selectView != nil) {
        NSArray *datas = [self datasFromCurrentModel];
        LLHierarchyModel *resultModel = nil;
        for (int i = 0; i < datas.count; i++) {
            LLHierarchyModel *model = datas[i];
            if (model.view == self.selectView) {
                resultModel = model;
                break;
            }
        }
        self.selectModel = resultModel;
    }
    if (self.selectModel && self.filterView.selectedSegmentIndex == 1) {
        NSArray *datas = [self datasFilterWithCurrentSelectView];
        [self.dataArray addObjectsFromArray:datas];
    } else {
        NSArray *datas = [self datasFilterWithFold];
        [self.dataArray addObjectsFromArray:datas];
    }
    [self.tableView reloadData];
}

- (void)scrollToSelectView {
    if (self.selectView != nil) {
        LLHierarchyModel *resultModel = nil;
        for (int i = 0; i < self.datas.count; i++) {
            LLHierarchyModel *model = self.datas[i];
            if (model.view == self.selectView) {
                resultModel = model;
                break;
            }
        }
        if (resultModel != nil) {
            self.selectModel = resultModel;
            LLHierarchyModel *currentModel = resultModel;
            LLHierarchyModel *parentModel = currentModel.parentModel;
            while (parentModel != nil) {
                if (parentModel.subModels.count > 1) {
                    NSInteger index = [parentModel.subModels indexOfObject:currentModel];
                    for (int i = 0; i < parentModel.subModels.count; i++) {
                        LLHierarchyModel *subModel = parentModel.subModels[i];
                        if (i != index) {
                            subModel.fold = YES;
                        }
                    }
                }
                currentModel = parentModel;
                parentModel = currentModel.parentModel;
            }
            
            [self reloadData];
            
            NSInteger index = [self.datas indexOfObject:resultModel];
            
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (NSMutableArray *)datasFromCurrentModel {
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    for (LLHierarchyModel *subModel in self.model.subModels) {
        [datas addObjectsFromArray:[self modelsFromModel:subModel checkFold:NO]];
    }
    return datas;
}

- (NSMutableArray *)datasFilterWithFold {
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    for (LLHierarchyModel *subModel in self.model.subModels) {
        [datas addObjectsFromArray:[self modelsFromModel:subModel checkFold:YES]];
    }
    return datas;
}

- (NSMutableArray *)modelsFromModel:(LLHierarchyModel *)model checkFold:(BOOL)checkFold {
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    [datas addObject:model];
    if (!checkFold || !model.isFold) {
        for (LLHierarchyModel *subModel in model.subModels) {
            [datas addObjectsFromArray:[self modelsFromModel:subModel checkFold:checkFold]];
        }
    }
    return datas;
}

- (NSMutableArray *)datasFilterWithCurrentSelectView {
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    [datas addObject:self.selectModel];
    LLHierarchyModel *parent = self.selectModel.parentModel;
    while (parent) {
        [datas insertObject:parent atIndex:0];
        parent = parent.parentModel;
    }
    return datas;
}

#pragma mark - LLHierarchyCellDelegate
- (void)LLHierarchyCellDidSelectFoldButton:(LLHierarchyCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    LLHierarchyModel *model = self.datas[indexPath.row];
    LLHierarchyModel *nextModel = nil;
    if (model.subModels.count) {
        if (self.datas.count > indexPath.row + 1) {
            nextModel = self.datas[indexPath.row + 1];
        }
        
        model.fold = !model.isFold;
        
        [self.tableView beginUpdates];
        
        NSArray *preData = [NSArray arrayWithArray:self.datas];
        NSArray *newData = [NSArray arrayWithArray:[self datasFilterWithFold]];
        
        NSMutableSet *preSet = [NSMutableSet setWithArray:preData];
        NSMutableSet *newSet = [NSMutableSet setWithArray:newData];
        
        NSMutableSet *intersectSet = [NSMutableSet setWithSet:preSet];
        [intersectSet intersectSet:newSet];
        
        [preSet minusSet:intersectSet];
        [newSet minusSet:intersectSet];
        
        
        NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        
        for (LLHierarchyModel *model in preSet.allObjects) {
            NSInteger index = [preData indexOfObject:model];
            [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        
        for (LLHierarchyModel *model in newSet.allObjects) {
            NSInteger index = [newData indexOfObject:model];
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        
        if (deleteIndexPaths.count) {
            [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        if (insertIndexPaths) {
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:newData];
        
        [self.tableView endUpdates];
        
        LLHierarchyCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell updateDirection];
        
        NSMutableArray *reloadIndexPaths = [[NSMutableArray alloc] init];
        if (self.datas.count > indexPath.row + 1) {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            [reloadIndexPaths addObject:nextIndexPath];
        }
        if (nextModel != nil && [self.datas containsObject:nextModel]) {
            NSInteger index = [self.datas indexOfObject:nextModel];
            NSIndexPath *preNextIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [reloadIndexPaths addObject:preNextIndexPath];
        }
        if (reloadIndexPaths.count) {
            [self.tableView reloadRowsAtIndexPaths:reloadIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)LLHierarchyCellDidSelectInfoButton:(LLHierarchyCell *)cell {
    
}

#pragma mark - TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLHierarchyCell *cell = [tableView dequeueReusableCellWithIdentifier:kHierarchyCellID forIndexPath:indexPath];
    cell.delegate = self;
    LLHierarchyModel *model = self.datas[indexPath.row];
    model.isSelectSection = self.filterView.selectedSegmentIndex == 1;
    [cell confirmWithModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self leftItemClick:self.leftNavigationButton];
    [self.delegate LLHierarchyViewController:self didFinishWithSelectedModel:self.datas[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectModel) {
        LLHierarchyModel *model = self.datas[indexPath.row];
        if (model == self.selectModel) {
            cell.selected = YES;
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [super searchBar:searchBar textDidChange:searchText];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [super tableView:tableView heightForHeaderInSection:section] + 40;
}

#pragma mark - Action
- (void)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 1 && self.selectModel == nil) {
        segmentedControl.selectedSegmentIndex = 0;
    } else {
        [self reloadData];
    }
}

#pragma mark - Lazy
- (UISegmentedControl *)filterView {
    if (!_filterView) {
        _filterView = [[UISegmentedControl alloc] initWithItems:@[@"In application",@"At tap"]];
        _filterView.tintColor = [LLThemeManager shared].primaryColor;
        _filterView.selectedSegmentIndex = 0;
        [_filterView addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _filterView;
}

@end
