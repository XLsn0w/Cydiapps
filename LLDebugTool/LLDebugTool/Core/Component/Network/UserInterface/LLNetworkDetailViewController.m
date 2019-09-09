//
//  LLNetworkDetailViewController.m
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

#import "LLNetworkDetailViewController.h"
#import "LLSubTitleTableViewCell.h"
#import "LLNetworkImageCell.h"
#import "LLConfig.h"
#import "UIImage+LL_Utils.h"
#import "LLToastUtils.h"

static NSString *const kNetworkContentCellID = @"NetworkContentCellID";
static NSString *const kNetworkImageCellID = @"NetworkImageCellID";

@interface LLNetworkDetailViewController () <LLSubTitleTableViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *titleArray;

@property (nonatomic, strong) NSMutableArray *contentArray;

@property (nonatomic, strong) NSArray *canCopyArray;

@end

@implementation LLNetworkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = self.contentArray[indexPath.row];
    // Config Image
    if ([obj isKindOfClass:[NSData class]] && self.model.isImage) {
        LLNetworkImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkImageCellID forIndexPath:indexPath];
        if (self.model.isGif) {
            [cell setUpImage:[UIImage LL_imageWithGIFData:obj]];
        } else {
            [cell setUpImage:[UIImage imageWithData:obj]];
        }
        return cell;
    }
    if ([obj isKindOfClass:[NSData class]]) {
        obj = [self convertDataToHexStr:obj];
    }
    
    LLSubTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNetworkContentCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.contentText = obj;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.titleArray[indexPath.row];
    if ([self.canCopyArray containsObject:title]) {
        id obj = self.contentArray[indexPath.row];
        if ([obj isKindOfClass:[NSData class]] && self.model.isImage) {
            UIImage *image = nil;
            if (self.model.isGif) {
                image = [UIImage LL_imageWithGIFData:obj];
            } else {
                image = [UIImage imageWithData:obj];
            }
            if ([image isKindOfClass:[UIImage class]]) {
                [[UIPasteboard generalPasteboard] setImage:image];
                [[LLToastUtils shared] toastMessage:[NSString stringWithFormat:@"Copy \"%@\" Success",title]];
            }
        } else if ([obj isKindOfClass:[NSData class]] || [obj isKindOfClass:[NSString class]]) {
            if ([obj isKindOfClass:[NSData class]]) {
                obj = [self convertDataToHexStr:obj];
            }
            [[UIPasteboard generalPasteboard] setString:obj];
            [[LLToastUtils shared] toastMessage:[NSString stringWithFormat:@"Copy \"%@\" Success",title]];
        }
    }
}

#pragma mark - LLSubTitleTableViewCellDelegate
- (void)LLSubTitleTableViewCell:(LLSubTitleTableViewCell *)cell didSelectedContentView:(UITextView *)contentTextView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - Primary
/**
 * initial method
 */
- (void)initial {
    self.navigationItem.title = @"Details";
    [self.tableView registerNib:[UINib nibWithNibName:@"LLNetworkImageCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kNetworkImageCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"LLSubTitleTableViewCell" bundle:[LLConfig shared].XIBBundle] forCellReuseIdentifier:kNetworkContentCellID];
    [self loadData];
}

- (void)loadData {
    if (self.model) {
        self.titleArray = [[NSMutableArray alloc] init];
        self.contentArray = [[NSMutableArray alloc] init];
        [self.titleArray addObject:@"Request Url"];
        [self.contentArray addObject:self.model.url.absoluteString?:@"unknown"];
        if (self.model.method) {
            [self.titleArray addObject:@"Method"];
            [self.contentArray addObject:self.model.method];
        }
        [self.titleArray addObject:@"Status Code"];
        [self.contentArray addObject:self.model.statusCode?:@"0"];
        
        if (self.model.error) {
            [self.titleArray addObject:@"Error"];
            [self.contentArray addObject:self.model.error.localizedDescription];
        }
        if (self.model.headerFields.count) {
            [self.titleArray addObject:@"Header Fields"];
            NSMutableString *string = [[NSMutableString alloc] init];
            for (NSString *key in self.model.headerFields) {
                [string appendFormat:@"%@ : %@\n",key,self.model.headerFields[key]];
            }
            [self.contentArray addObject:string];
        }
        if (self.model.mimeType) {
            [self.titleArray addObject:@"Mime Type"];
            [self.contentArray addObject:self.model.mimeType];
        }
        if (self.model.startDate) {
            [self.titleArray addObject:@"Start Date"];
            [self.contentArray addObject:self.model.startDate];
        }
        if (self.model.totalDuration) {
            [self.titleArray addObject:@"Total Duration"];
            [self.contentArray addObject:self.model.totalDuration];
        }
        if (self.model.totalDataTraffic) {
            [self.titleArray addObject:@"Data Traffic"];
            [self.contentArray addObject:[NSString stringWithFormat:@"%@ (%@↑ / %@↓)",self.model.totalDataTraffic,self.model.requestDataTraffic,self.model.responseDataTraffic]];
        }
        
        [self.titleArray addObject:@"Request Body"];
        [self.contentArray addObject:self.model.requestBody ?: @"Null"];
        if (self.model.responseData) {
            [self.titleArray addObject:@"Response Body"];
            if (self.model.isImage) {
                [self.contentArray addObject:self.model.responseData];
            } else {
                [self.contentArray addObject:self.model.responseString.length ? self.model.responseString : self.model.responseData];
            }
        }
    }
}

- (NSArray *)canCopyArray {
    if (!_canCopyArray) {
        _canCopyArray = @[@"Request Url", @"Error", @"Header Fields" ,@"Request Body",@"Response Body"];
    }
    return _canCopyArray;
}

- (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

@end
