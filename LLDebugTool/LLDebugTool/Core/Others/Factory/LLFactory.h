//
//  LLFactory.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LLBaseMoveView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LLFactory : NSObject

#pragma mark - UIView
/**
 Get view.

 @return UIView.
 */
+ (UIView *)getView;

/**
 Get view with superview.

 @param toView superview.
 @return UIView.
 */
+ (UIView *)getView:(UIView *_Nullable)toView;

/**
 Get view with params.

 @param toView superview.
 @param frame frame size.
 @return UIView.
 */
+ (UIView *)getView:(UIView *_Nullable)toView
                      frame:(CGRect)frame;

/**
 Get view with params.

 @param toView superview.
 @param frame frame size.
 @param backgroundColor background color.
 @return UIView
 */
+ (UIView *)getView:(UIView *_Nullable)toView
                      frame:(CGRect)frame
            backgroundColor:(UIColor *_Nullable)backgroundColor;

/**
 Get primary view.

 @return UIView.
 */
+ (UIView *)getPrimaryView;

/**
 Get primary view with superview.

 @param toView superview.
 @return UIView.
 */
+ (UIView *)getPrimaryView:(UIView *_Nullable)toView;

/**
 Get primary view with params.

 @param toView superview.
 @param frame frame size.
 @return UIView
 */
+ (UIView *)getPrimaryView:(UIView *_Nullable)toView
                             frame:(CGRect)frame;

/**
 Get primary view with params.

 @param toView superview.
 @param frame frame size.
 @param alpha alpha value.
 @return UIView.
 */
+ (UIView *)getPrimaryView:(UIView *_Nullable)toView
                             frame:(CGRect)frame
                             alpha:(CGFloat)alpha;

/**
 Get background view.

 @return UIView.
 */
+ (UIView *)getBackgroundView;

/**
 Get background view with superview.

 @param toView superview.
 @return UIView.
 */
+ (UIView *)getBackgroundView:(UIView *_Nullable)toView;

/**
 Get background view with params.

 @param toView superview.
 @param frame frame size.
 @return UIView.
 */
+ (UIView *)getBackgroundView:(UIView *_Nullable)toView
                                frame:(CGRect)frame;

/**
 Get background view with params.

 @param toView superview.
 @param frame frame size.
 @param alpha alpha value.
 @return UIView.
 */
+ (UIView *)getBackgroundView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                                alpha:(CGFloat)alpha;

/**
 Create lines of unity.
 */
+ (UIView *)lineView:(CGRect)frame
                   superView:(UIView *_Nullable)superView;

#pragma mark - UILabel
/**
 Get Label.

 @return UILabel.
 */
+ (UILabel *)getLabel;

/**
 Get label with superview.

 @param toView superview.
 @return UILabel.
 */
+ (UILabel *)getLabel:(UIView *_Nullable)toView;

/**
 Get label with params.

 @param toView superview.
 @param frame frame size.
 @return UILabel
 */
+ (UILabel *)getLabel:(UIView *_Nullable)toView
                        frame:(CGRect)frame;

/**
 Get label with params.

 @param toView superview.
 @param frame frame size.
 @param text text string.
 @param fontSize font size.
 @param textColor text color.
 @return UILabel
 */
+ (UILabel *)getLabel:(UIView *_Nullable)toView
                        frame:(CGRect)frame
                         text:(NSString *_Nullable)text
                         font:(CGFloat)fontSize
                    textColor:(UIColor *_Nullable)textColor;

#pragma mark - UITextView
/**
 Get textView.

 @return UITextView.
 */
+ (UITextView *)getTextView;

/**
 Get textView with superview.

 @param toView superview.
 @return UITextView.
 */
+ (UITextView *)getTextView:(UITextView *_Nullable)toView;

/**
 Get textView with params.

 @param toView superview.
 @param frame frame size.
 @return UITextView.
 */
+ (UITextView *)getTextView:(UITextView *_Nullable)toView
                              frame:(CGRect)frame;

/**
 Get textView with params.

 @param toView superview.
 @param frame frame size.
 @param delegate Delegate.
 @return UITextView.
 */
+ (UITextView *)getTextView:(UITextView *_Nullable)toView
                              frame:(CGRect)frame
                           delegate:(id<UITextViewDelegate>_Nullable)delegate;

#pragma mark - UIImageView
/**
 Get imageView.

 @return UIImageView.
 */
+ (UIImageView *)getImageView;

/**
 Get imageView with superview.

 @param toView superview.
 @return UIImageView.
 */
+ (UIImageView *)getImageView:(UIView *_Nullable)toView;

/**
 Get imageView with params.

 @param toView superview.
 @param frame frame size.
 @return UIImageView.
 */
+ (UIImageView *)getImageView:(UIView *_Nullable)toView
                                frame:(CGRect)frame;

/**
 Get imageView with params.

 @param toView superview.
 @param frame frame size.
 @param image image
 @return UIImage.
 */
+ (UIImageView *)getImageView:(UIView *_Nullable)toView
                        frame:(CGRect)frame
                        image:(UIImage *_Nullable)image;

#pragma mark - UIButton

/**
 Get button.

 @return UIButton.
 */
+ (UIButton *)getButton;

/**
 Get button with superview.

 @param toView superview.
 @return UIButton
 */
+ (UIButton *)getButton:(UIView *_Nullable)toView;

/**
 Get button with params.

 @param toView superview.
 @param frame frame size.
 @return UIButton
 */
+ (UIButton *)getButton:(UIView *_Nullable)toView
                          frame:(CGRect)frame;

/**
 Get button with params.

 @param toView superview.
 @param frame frame size.
 @param target action's target.
 @param action action.
 @return UIButton.
 */
+ (UIButton *)getButton:(UIView *_Nullable)toView
                          frame:(CGRect)frame
                         target:(id _Nullable)target
                         action:(SEL _Nullable)action;

#pragma mark - UITableView
/**
 Get tableView.

 @return UITableView.
 */
+ (UITableView *)getTableView;

/**
 Get tableView with superview.

 @param toView superview.
 @return UITableView.
 */
+ (UITableView *)getTableView:(UIView *_Nullable)toView;

/**
 Get tableView with params.

 @param toView superview.
 @param frame frame size.
 @return UITableView.
 */
+ (UITableView *)getTableView:(UIView *_Nullable)toView
                                frame:(CGRect)frame;

/**
 Get tableView with params.

 @param toView superview
 @param frame frame size.
 @param delegate Delegate.
 @return UITableView.
 */
+ (UITableView *)getTableView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                             delegate:(id<UITableViewDelegate, UITableViewDataSource>_Nullable)delegate;
/**
 Get tableView with params.

 @param toView superview.
 @param frame frame size.
 @param delegate Delegate.
 @param style style of table.
 @return UITableView.
 */
+ (UITableView *)getTableView:(UIView *_Nullable)toView
                                frame:(CGRect)frame
                             delegate:(id<UITableViewDelegate, UITableViewDataSource>_Nullable)delegate
                                style:(UITableViewStyle)style;

#pragma mark - UICollectionView

/**
 Get collectionView.

 @param layout collectionView layout.
 @return UICollectionView.
 */
+ (UICollectionView *)getCollectionViewWithLayout:(UICollectionViewFlowLayout *)layout;

/**
 Get collectionView with superview.
 
 @param toView superview.
 @param layout collectionView layout.
 @return UICollectionView.
 */
+ (UICollectionView *)getCollectionView:(UIView *_Nullable)toView
                                         layout:(UICollectionViewFlowLayout *)layout;

/**
 Get collectionView with params.
 
 @param toView superview.
 @param frame frame size.
 @param layout collectionView layout.
 @return UICollectionView.
 */
+ (UICollectionView *)getCollectionView:(UIView *_Nullable)toView
                                          frame:(CGRect)frame
                                         layout:(UICollectionViewFlowLayout *)layout;

/**
 Get collectionView with params.
 
 @param toView superview.
 @param frame frame size.
 @param delegate Delegate.
 @param layout collectionView layout.
 @return UICollectionView.
 */
+ (UICollectionView *)getCollectionView:(UIView *_Nullable)toView
                                          frame:(CGRect)frame
                                       delegate:(id<UICollectionViewDelegate, UICollectionViewDataSource>_Nullable)delegate
                                         layout:(UICollectionViewFlowLayout *)layout;

#pragma mark - UISegmentedControl

/**
 Get SegmentedControl

 @return UISegmentedControl.
 */
+ (UISegmentedControl *)getSegmentedControl;

/**
 Get SegmentedControl with superview.

 @param toView superview.
 @return UISegmentedControl.
 */
+ (UISegmentedControl *)getSegmentedControl:(UIView *_Nullable)toView;

/**
 Get SegmentedControl with params.

 @param toView superview.
 @param frame frame size.
 @return UISegmentedControl.
 */
+ (UISegmentedControl *)getSegmentedControl:(UIView *_Nullable)toView
                                      frame:(CGRect)frame;

/**
 Get SegmentedControl with params.

 @param toView superview.
 @param frame frame size.
 @param items items.
 @return UISegmentedControl.
 */
+ (UISegmentedControl *)getSegmentedControl:(UIView *_Nullable)toView
                                      frame:(CGRect)frame
                                      items:(nullable NSArray *)items;

@end

NS_ASSUME_NONNULL_END
