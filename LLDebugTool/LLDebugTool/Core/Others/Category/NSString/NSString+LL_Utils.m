//
//  NSString+LL_Utils.m
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

#import "NSString+LL_Utils.h"

@implementation NSString (LL_Utils)

- (NSDictionary *)LL_toJsonDictionary {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:0
                                                              error:&error];
        if (!error) {
            return dic;
        }
    }
    return nil;
}

- (NSArray *)LL_jsonArray {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:0
                                                              error:&error];
        if (!error) {
            return array;
        }
    }
    return nil;
}

- (unsigned long long)LL_byteLength {
    if (self.length == 0) {
        return 0;
    }
    unsigned long long length = 0;
    char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (NSInteger i = 0 ; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ; i++)
    {
        if (*p) {
            p++;
            length++;
        } else {
            p++;
        }
    }
    return (length + 1) / 2;
}

- (CGFloat)LL_heightWithAttributes:(NSDictionary *)attributes maxWidth:(CGFloat)maxWidth minHeight:(CGFloat)minHeight {
    if (self.length == 0) {
        return 0;
    }
    CGRect rect = [self boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    // Sometime, it's a little small.
    rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + 4, rect.size.height + 4);
    return rect.size.height > minHeight ? rect.size.height : minHeight;
}

@end
