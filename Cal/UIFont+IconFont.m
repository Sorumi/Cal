//
//  UIFont+IconFont.m
//  Cal
//
//  Created by Sorumi on 16/8/19.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "UIFont+IconFont.h"
#import "NSString+IconFont.h"

@implementation UIFont (IconFont)

#pragma mark - Public

+ (UIFont *)iconfontOfSize:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:iconfontFamilyName size:size];
    NSAssert(font!=nil, @"%@ couldn't be loaded",iconfontFamilyName);
    return font;
}

@end