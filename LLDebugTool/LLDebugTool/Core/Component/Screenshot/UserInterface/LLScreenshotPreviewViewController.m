//
//  LLScreenshotPreviewViewController.m
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

#import "LLScreenshotPreviewViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import "LLScreenshotBaseOperation.h"
#import "LLScreenshotImageView.h"
#import "LLScreenshotToolbar.h"
#import "LLScreenshotHelper.h"
#import "LLMacros.h"
#import "UIView+LL_Utils.h"
#import "LLFormatterTool.h"
#import "LLToastUtils.h"
#import "LLConst.h"

@interface LLScreenshotPreviewViewController () <LLScreenshotToolbarDelegate>

@property (nonatomic, strong) LLScreenshotImageView *imageView;

@property (nonatomic, strong) LLScreenshotToolbar *toolBar;

@property (nonatomic, assign) CGRect originalImageFrame;

@property (nonatomic, copy) NSString *name;

@end

@implementation LLScreenshotPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

#pragma mark - Primary
- (void)initial {
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.name = [[LLFormatterTool shared] stringFromDate:[NSDate date] style:FormatterToolDateStyle3];
    
    CGFloat rate = 0.1;
    CGFloat toolBarHeight = 80;
    CGFloat imgViewWidth = (1 - rate * 2) * LL_SCREEN_WIDTH;
    CGFloat imgViewHeight = (1 - rate * 2) * LL_SCREEN_HEIGHT;
    CGFloat imgViewTop = (rate * 2 * LL_SCREEN_HEIGHT - toolBarHeight) / 2.0;
    // Init ImageView
    self.imageView = [[LLScreenshotImageView alloc] initWithFrame:CGRectMake(rate * LL_SCREEN_WIDTH, imgViewTop, imgViewWidth, imgViewHeight)];
    self.originalImageFrame = self.imageView.frame;
    self.imageView.image = self.image;
    [self.view addSubview:self.imageView];
    
    // Init Controls
    self.toolBar = [[LLScreenshotToolbar alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y + self.imageView.frame.size.height + kLLGeneralMargin, self.imageView.frame.size.width, toolBarHeight)];
    self.toolBar.delegate = self;
    [self.view addSubview:self.toolBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cancelAction {
    [self componentDidLoad:nil];
}

- (void)confirmAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Note" message:@"Enter the image name" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * textField) {
        textField.text = self.name;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self doConfirmAction:alert.textFields.firstObject.text];
    }];
    [alert addAction:cancel];
    [alert addAction:confirm];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doConfirmAction:(NSString *)name {
    self.toolBar.hidden = YES;
    UIImage *image = [self.imageView LL_convertViewToImage];
    if (image) {
        [[LLScreenshotHelper shared] saveScreenshot:image name:name complete:nil];
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            [[LLToastUtils shared] toastMessage:@"Save image in sandbox and album."];
        } else {
            [[LLToastUtils shared] toastMessage:@"Save image in sandbox."];
        }
    } else {
        self.toolBar.hidden = NO;
        [[LLToastUtils shared] toastMessage:@"Save image failed."];
    }
    [self componentDidLoad:nil];
}

#pragma mark - LLScreenshotToolbarDelegate
- (void)LLScreenshotToolbar:(LLScreenshotToolbar *)toolBar didSelectedAction:(LLScreenshotAction)action selectorModel:(LLScreenshotSelectorModel *)selectorModel {
    if (action <= LLScreenshotActionText) {
        self.imageView.currentAction = action;
        self.imageView.currentSelectorModel = selectorModel;
    } else if (action == LLScreenshotActionBack) {
        [self.imageView removeLastOperation];
    } else if (action == LLScreenshotActionCancel) {
        [self cancelAction];
    } else if (action == LLScreenshotActionConfirm) {
        [self confirmAction];
    }
}

#pragma mark - NSNotification
- (void)keyboardWillShowNotification:(NSNotification *)notifi {
    NSDictionary *userInfo = notifi.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ([self.imageView.currentOperation isKindOfClass:[LLScreenshotTextOperation class]]) {
        LLScreenshotTextOperation *operation = (LLScreenshotTextOperation *)self.imageView.currentOperation;
        CGFloat y = operation.textView.frame.origin.y + self.originalImageFrame.origin.y;
        CGFloat gap = y - endFrame.origin.y + 100;
        if (gap > 0) {
            [UIView animateWithDuration:duration animations:^{
                CGRect oriRect = self.imageView.frame;
                self.imageView.frame = CGRectMake(oriRect.origin.x, self.originalImageFrame.origin.y - gap, oriRect.size.width, oriRect.size.height);
            }];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notifi {
    NSDictionary *userInfo = notifi.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (!CGRectEqualToRect(self.imageView.frame, self.originalImageFrame)) {
        [UIView animateWithDuration:duration animations:^{
            self.imageView.frame = self.originalImageFrame;
        }];
    }
}

@end
