//
//  UIImage+LL_Utils.m
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

#import "UIImage+LL_Utils.h"
#import "LLConfig.h"

@implementation UIImage (LL_Utils)

+ (UIImage *)LL_imageNamed:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[LLConfig shared].imageBundle compatibleWithTraitCollection:nil];
}

+ (UIImage *_Nullable)LL_imageNamed:(NSString *)name size:(CGSize)size {
    return [[self LL_imageNamed:name] LL_resizeTo:size];
}

+ (UIImage *_Nullable)LL_imageNamed:(NSString *)name color:(UIColor *)color {
    return [[self LL_imageNamed:name] LL_colorTo:color];
}

+ (UIImage *_Nullable)LL_imageNamed:(NSString *)name size:(CGSize)size color:(UIColor *)color {
    return [[self LL_imageNamed:name size:size] LL_colorTo:color];
}

+ (nullable UIImage *)LL_imageWithGIFData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0.0f;
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            duration += [self LL_frameDurationAtIndex:i source:source];
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            CGImageRelease(image);
        }
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    CFRelease(source);
    return animatedImage;
}

+ (float)LL_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)LL_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)LL_resizeTo:(CGSize)size {
    // Create a context for the bitmap and set it to the current context being used.
    UIGraphicsBeginImageContext(size);
    // Draws a resizing image.
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // Create a resized image from the current context.
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // Causes the current context to exit the stack
    UIGraphicsEndImageContext();
    // Return new image.
    return newImage;
}

- (UIImage *)LL_colorTo:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSArray <NSArray <NSString *>*>*)LL_hexColors {
    
    CGImageRef cgimage = [self CGImage];
    size_t width = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    unsigned char *data = calloc(width * height * 4, sizeof(unsigned char));
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = width * 4; // RGBA
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 space,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    NSMutableArray *hexColors = [[NSMutableArray alloc] initWithCapacity:height];
    for (size_t i = 0; i < height; i++) {
        NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:width];
        for (size_t j = 0; j < width; j++) {
            size_t pixelIndex = i * width * 4 + j * 4;
            unsigned char red = data[pixelIndex];
            unsigned char green = data[pixelIndex + 1];
            unsigned char blue = data[pixelIndex + 2];
            
            NSString *hexColor = [NSString stringWithFormat:@"#%02x%02x%02x",red,green,blue];
            [colors addObject:hexColor];
        }
        [hexColors addObject:colors];
    }
    
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    free(data);
    return hexColors;
}

- (NSString *)LL_hexColorAt:(CGPoint)point {

    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSString *hexColor = nil;
    
    @synchronized (self) {
        NSInteger pointX = trunc(point.x);
        NSInteger pointY = trunc(point.y);
        CGImageRef cgImage = self.CGImage;
        NSUInteger width = self.size.width;
        NSUInteger height = self.size.height;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        int bytesPerPixel = 4;
        int bytesPerRow = bytesPerPixel * 1;
        NSUInteger bitsPerComponent = 8;
        unsigned char pixelData[4] = { 0 };
        CGContextRef context = CGBitmapContextCreate(pixelData,
                                                     1,
                                                     1,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextSetBlendMode(context, kCGBlendModeCopy);
        
        CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
        CGContextRelease(context);
        
        // Here is a bug, The first row pixelData will always be "#000000", but the second row data is real first row data.
        hexColor = [NSString stringWithFormat:@"#%02X%02X%02X",pixelData[0],pixelData[1],pixelData[2]];
    }
    return hexColor;
}

@end
