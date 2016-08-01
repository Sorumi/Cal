//
//  SRMCalendarAppearance.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarAppearance.h"

@interface SRMCalendarAppearance ()

@property (nonatomic, strong) NSMutableDictionary *privateDictionary;

@end

@implementation SRMCalendarAppearance

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

+ (instancetype)appearanceDictionary
{
    static SRMCalendarAppearance *appearanceStore = nil;
    
    if (!appearanceStore) {
        appearanceStore = [[self alloc] initPrivate];
    }
    return appearanceStore;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        _privateDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{@"CalendarHeaderColor": UIColorFromRGB(0xD1E6E2),
                                                                               @"CalendarMonthBorderColor": UIColorFromRGB(0xD1E6E2),
                                                                               @"MonthViewWeekdayFontColor": UIColorFromRGB(0xDFEBE9),
                                                                               @"WeekViewWeekdayFontColor": UIColorFromRGB(0xEEEEEE),
                                                                               @"WeekViewDateFontColor":  UIColorFromRGB(0x404040),
                                                                               @"WeekViewDayCircleColor": UIColorFromRGB(0xECF4F2)
                                                                               }];
    }
    return  self;
}

- (NSDictionary *)appearanceDictionary
{
    return self.privateDictionary;
}

- (UIColor *)colorForKey:(NSString *)key
{
    return self.privateDictionary[key];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[SRMCalendarAppearance appearanceDictionary]" userInfo:nil];
    return nil;
}

@end
