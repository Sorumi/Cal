//
//  NSString+IconFont.h
//  Cal
//
//  Created by Sorumi on 16/8/19.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const iconfontFamilyName = @"iconfont";

typedef NS_ENUM(NSInteger, IFIcon) {
    IFArrowLeft,
    IFArrowRight,
    IFBell,
    IFCalendar,
    IFClock,
    IFCross,
    IFLocation,
    IFNote,
    IFPaintRoll,
    IFRepeat,
    IFSquareBlank,
    IFSquareCheck,
    IFTick,
    IFTrashCan,
    IFAdd,
    IFSquareSelect
};

@interface NSString (IconFont)

+ (NSString *)iconfontIconStringForEnum:(IFIcon)value;

@end