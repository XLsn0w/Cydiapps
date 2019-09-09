//
//  LLHierarchyModel.m
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

#import "LLHierarchyModel.h"
#import "LLTool.h"

@implementation LLHierarchyModel

- (instancetype _Nonnull)initWithView:(UIView *)view section:(NSInteger)section row:(NSInteger)row subModels:(NSMutableArray <LLHierarchyModel *>*_Nullable)subModels {
    if (self = [super init]) {
        _view = view;
        _section = section;
        _row = row;
        _subModels = subModels;
        for (LLHierarchyModel *model in subModels) {
            [model setValue:self forKey:@"parentModel"];
        }
    }
    return self;
}

- (instancetype _Nonnull)initWithSubModels:(NSMutableArray <LLHierarchyModel *>*)subModels {
    if (self = [super init]) {
        _subModels = subModels;
        _isRoot = YES;
    }
    return self;
}

- (NSString *)name {
    return NSStringFromClass(_view.class);
}

- (NSString *)frame {
    return [LLTool stringFromFrame:_view.frame];
}

- (BOOL)isSingleInCurrentSection {
    return self.parentModel.subModels.count == 1;
}

- (BOOL)isFirstInCurrentSection {
    return self.parentModel.subModels.firstObject == self;
}

- (BOOL)isLastInCurrentSection {
    return self.parentModel.subModels.lastObject == self;
}

- (LLHierarchyModel *)lastModelInCurrentSection {
    if ([self isFirstInCurrentSection]) {
        return nil;
    }
    NSInteger index = [self.parentModel.subModels indexOfObject:self];
    return [self.parentModel.subModels objectAtIndex:index - 1];
}

@end
