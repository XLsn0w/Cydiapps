//
//  UIColor+LL_Utils.m
//
//  Copyright (c) 2018 LLBaseFoundation Software Foundation (https://github.com/HDB-Li/LLDebugTool)
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

#import "UIColor+LL_Utils.h"

@implementation UIColor (LL_Utils)

+ (UIColor *)LL_colorWithHex:(NSString *)hex {
    if ([hex length] < 6){//长度不合法
        return [UIColor blackColor];
    }
    NSString *tempString = [hex lowercaseString];
    if ([tempString hasPrefix:@"0x"]) {//检查开头是0x
        tempString = [tempString substringFromIndex:2];
    } else if ([tempString hasPrefix:@"#"]) {//检查开头是#
        tempString = [tempString substringFromIndex:1];
    }
    if ([tempString length] != 6){
        return [UIColor blackColor];
    }
    
    //分解三种颜色的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [tempString substringWithRange:range];
    range.location = 2;
    NSString *gString = [tempString substringWithRange:range];
    range.location = 4;
    NSString *bString = [tempString substringWithRange:range];
    
    //取三种颜色值
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (NSArray *)LL_RGBA {
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return @[@(r),@(g),@(b),@(a)];
}

- (NSString *)LL_HexString {
    NSArray *rgba = [self LL_RGBA];
    int r = [rgba[0] doubleValue] * 255.0;
    int g = [rgba[1] doubleValue] * 255.0;
    int b = [rgba[2] doubleValue] * 255.0;
    return [NSString stringWithFormat:@"#%02X%02X%02X",r, g, b];
}

- (NSString *)LL_description {
    if ([self isEqual:[UIColor clearColor]]) {
        return @"Clear Color";
    }
    
    NSString *color = @"";
    if ([self isEqual:[UIColor blackColor]]) {
        color = @"Black Color";
    } else if ([self isEqual:[UIColor darkGrayColor]]) {
        color = @"DarkGray Color";
    } else if ([self isEqual:[UIColor lightGrayColor]]) {
        color = @"LightGray Color";
    } else if ([self isEqual:[UIColor whiteColor]]) {
        color = @"White Color";
    } else if ([self isEqual:[UIColor grayColor]]) {
        color = @"Gray Color";
    } else if ([self isEqual:[UIColor redColor]]) {
        color = @"Red Color";
    } else if ([self isEqual:[UIColor greenColor]]) {
        color = @"Green Color";
    } else if ([self isEqual:[UIColor blueColor]]) {
        color = @"Blue Color";
    } else if ([self isEqual:[UIColor cyanColor]]) {
        color = @"Cyan Color";
    } else if ([self isEqual:[UIColor yellowColor]]) {
        color = @"Yellow Color";
    } else if ([self isEqual:[UIColor magentaColor]]) {
        color = @"Magenta Color";
    } else if ([self isEqual:[UIColor orangeColor]]) {
        color = @"Orange Color";
    } else if ([self isEqual:[UIColor purpleColor]]) {
        color = @"Purple Color";
    } else if ([self isEqual:[UIColor brownColor]]) {
        color = @"Brown Color";
    }
    
    NSArray *rgba = [self LL_RGBA];
    int r = [rgba[0] doubleValue] * 255.0;
    int g = [rgba[1] doubleValue] * 255.0;
    int b = [rgba[2] doubleValue] * 255.0;
    int a = [rgba[3] doubleValue] * 255.0;
    
    if ([color length]) {
        color = [color stringByAppendingFormat:@" (#%02X%02X%02X)", r, g, b];
    } else {
        color = [NSString stringWithFormat:@"#%02X%02X%02X", r, g, b];
    }
    
    if (a < 255) {
        color = [color stringByAppendingFormat:@", Alpha: %0.2f", [rgba[3] doubleValue]];
    }
    
    return color;
}

- (UIColor *)LL_mixtureWithColor:(UIColor *)color radio:(CGFloat)radio {
    NSArray *colors1 = [self LL_RGBA];
    NSArray *colors2 = [color LL_RGBA];
    
    CGFloat r = [colors2[0] doubleValue] * radio + [colors1[0] doubleValue] * (1 - radio);
    CGFloat g = [colors2[1] doubleValue] * radio + [colors1[1] doubleValue] * (1 - radio) ;
    CGFloat b = [colors2[2] doubleValue] * radio + [colors1[2] doubleValue] * (1 - radio);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
