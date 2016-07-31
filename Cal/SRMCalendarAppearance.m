//
//  SRMCalendarAppearance.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarAppearance.h"

@implementation SRMCalendarAppearance

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.calendarHeaderColor = UIColorFromRGB(0xD1E6E2);
        self.calendarMonthBorderColor = UIColorFromRGB(0xD1E6E2);
        self.monthWeekdayFontColor = UIColorFromRGB(0xDFEBE9);
        self.weekViewDateFontColor = UIColorFromRGB(0x808080);
    }
    return self;
}

@end
