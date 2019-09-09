//
//  LLFactory.m
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

#import "LLFactory.h"
#import "LLConfig.h"
#import "LLMacros.h"
#import "LLThemeManager.h"

@implementation LLFactory

#pragma mark - UIView
+ (UIView *)getView {
    return [self getView:nil];
}

+ (UIView *)getView:(UIView *_Nullable)toView {
    return [self getView:toView
                   frame:CGRectZero];
}

+ (UIView *)getView:(UIView *_Nullable)toView
                      frame:(CGRect)frame {
    return [self getView:toView
                   frame:frame
         backgroundColor:nil];
}

+ (UIView *)getView:(UIView *_Nullable)toView
                      frame:(CGRect)frame
            backgroundColor:(UIColor *_Nullable)backgroundColor {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [toView addSubview:view];
    view.backgroundColor = backgroundColor;
    return view;
}

+ (UIView *)getPrimaryView {
    return [self getPrimaryView:nil];
}

+ (UIView *)getPrimaryView:(UIView *_Nullable)toView {
    return [self getPrimaryView:toView
                          frame:CGRectZero];
}

+ (UIView *)getPrimaryView:(UIView *_Nullable)toView
                             frame:(CGRect)frame {
    return [self getPrimaryView:toView
                          frame:frame
                          alpha:1];
}

+ (UIView *)getPrimaryView:(UIView *_Nullable)toView
                             frame:(CGRect)frame alpha:(CGFloat)alpha {
    return [self getView:toView
                   frame:frame
         backgroundColor:[[LLThemeManager shared].primaryColor colorWithAlphaComponent:alpha]];
}

+ (UIView *)getBackgroundView {
    return [self getBackgroundView:nil];
}

+ (UIView *)getBackgroundView:(UIView *_Nullable)toView {
    return [self getBackgroundView:toView
                             frame:CGRectZero];
}

+ (UIView *)getBackgroundView:(UIView *_Nullable)toView
                                frame:(CGRect)frame {
    return [self getBackgroundView:toView
                             frame:frame
                             alpha:1];
}

+ (UIView *)getBackgroundView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                                alpha:(CGFloat)alpha {
    return [self getView:toView
                   frame:frame
         backgroundColor:[[LLThemeManager shared].backgroundColor colorWithAlphaComponent:alpha]];
}

+ (UIView *)lineView:(CGRect)frame
                   superView:(UIView *_Nullable)superView {
    UIView *view = [self getPrimaryView:superView];
    return view;
}

#pragma mark - UILabel
+ (UILabel *)getLabel {
    return [self getLabel:nil];
}

+ (UILabel *)getLabel:(UIView *_Nullable)toView {
    return [self getLabel:toView
                    frame:CGRectZero];
}

+ (UILabel *)getLabel:(UIView *_Nullable)toView
                        frame:(CGRect)frame {
    return [self getLabel:toView frame:CGRectZero text:nil font:17 textColor:nil];
}

+ (UILabel *)getLabel:(UIView *_Nullable)toView
                        frame:(CGRect)frame
                         text:(NSString *_Nullable)text
                         font:(CGFloat)fontSize
                    textColor:(UIColor *_Nullable)textColor {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [toView addSubview:label];
    label.text = text;
    label.font = [UIFont systemFontOfSize:fontSize];
    if (textColor) {
        label.textColor = textColor;
    }
    return label;
}

#pragma mark - UITextView
+ (UITextView *)getTextView {
    return [self getTextView:nil];
}

+ (UITextView *)getTextView:(UITextView *_Nullable)toView {
    return [self getTextView:toView frame:CGRectZero];
}

+ (UITextView *)getTextView:(UITextView *_Nullable)toView
                              frame:(CGRect)frame {
    return [self getTextView:toView frame:frame delegate:nil];
}

+ (UITextView *)getTextView:(UITextView *_Nullable)toView
                              frame:(CGRect)frame
                           delegate:(id<UITextViewDelegate>_Nullable)delegate {
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    [toView addSubview:textView];
    textView.delegate = delegate;
    return textView;
}

#pragma mark - UIImageView
+ (UIImageView *)getImageView {
    return [self getImageView:nil];
}

+ (UIImageView *)getImageView:(UIView *_Nullable)toView {
    return [self getImageView:toView frame:CGRectZero];
}

+ (UIImageView *)getImageView:(UIView *_Nullable)toView
                                frame:(CGRect)frame {
    return [self getImageView:toView frame:frame image:nil];
}

+ (UIImageView *)getImageView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                                image:(UIImage *_Nullable)image {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [toView addSubview:imageView];
    imageView.image = image;
    return imageView;
}

#pragma mark - UIButton
+ (UIButton *)getButton {
    return [self getButton:nil];
}

+ (UIButton *)getButton:(UIView *_Nullable)toView {
    return [self getButton:toView frame:CGRectZero];
}

+ (UIButton *)getButton:(UIView *_Nullable)toView frame:(CGRect)frame {
    return [self getButton:toView frame:frame target:nil action:nil];
}

+ (UIButton *)getButton:(UIView *_Nullable)toView frame:(CGRect)frame target:(id _Nullable)target action:(SEL _Nullable)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [toView addSubview:button];
    button.frame = frame;
    button.adjustsImageWhenHighlighted = NO;
    if (target && action) {
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

#pragma mark - UITableView
+ (UITableView *)getTableView {
    return [self getTableView:nil];
}

+ (UITableView *)getTableView:(UIView *_Nullable)toView {
    return [self getTableView:toView frame:CGRectZero];
}

+ (UITableView *)getTableView:(UIView *_Nullable)toView
                                frame:(CGRect)frame {
    return [self getTableView:toView frame:frame delegate:nil];
}

+ (UITableView *)getTableView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                             delegate:(id<UITableViewDelegate, UITableViewDataSource>_Nullable)delegate {
    return [self getTableView:toView frame:frame delegate:delegate style:UITableViewStylePlain];
}

+ (UITableView *)getTableView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                             delegate:(id<UITableViewDelegate, UITableViewDataSource>_Nullable)delegate
                                style:(UITableViewStyle)style {
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:style];
    [toView addSubview:tableView];
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedRowHeight = 50;
    tableView.rowHeight = UITableViewAutomaticDimension;
    // To Control subviews.
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.tableHeaderView = [LLFactory getView:nil frame:CGRectMake(0, 0, LL_SCREEN_WIDTH, CGFLOAT_MIN)];
    tableView.tableFooterView = [LLFactory getView:nil frame:CGRectMake(0, 0, LL_SCREEN_WIDTH, CGFLOAT_MIN)];
    return tableView;
}

#pragma mark - UICollectionView
+ (UICollectionView *)getCollectionViewWithLayout:(UICollectionViewFlowLayout *)layout {
    return [self getCollectionView:nil layout:layout];
}

+ (UICollectionView *)getCollectionView:(UIView *_Nullable)toView
                                         layout:(UICollectionViewFlowLayout *)layout {
    return [self getCollectionView:toView frame:CGRectZero layout:layout];
}

+ (UICollectionView *)getCollectionView:(UIView *_Nullable)toView
                                          frame:(CGRect)frame
                                         layout:(UICollectionViewFlowLayout *)layout {
    return [self getCollectionView:toView frame:frame delegate:nil layout:layout];
}

+ (UICollectionView *)getCollectionView:(UIView *_Nullable)toView
                                          frame:(CGRect)frame
                                       delegate:(id<UICollectionViewDelegate, UICollectionViewDataSource>_Nullable)delegate
                                         layout:(UICollectionViewFlowLayout *)layout {
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [toView addSubview:collectionView];
    collectionView.delegate = delegate;
    collectionView.dataSource = delegate;
    return collectionView;
}

#pragma mark - UISegmentedControl
+ (UISegmentedControl *)getSegmentedControl {
    return [self getSegmentedControl:nil];
}

+ (UISegmentedControl *)getSegmentedControl:(UIView *)toView {
    return [self getSegmentedControl:toView frame:CGRectZero];
}

+ (UISegmentedControl *)getSegmentedControl:(UIView *)toView frame:(CGRect)frame {
    return [self getSegmentedControl:toView frame:frame items:nil];
}

+ (UISegmentedControl *)getSegmentedControl:(UIView *)toView frame:(CGRect)frame items:(NSArray *)items {
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:items];
    [toView addSubview:control];
    control.frame = frame;
    return control;
}

@end
