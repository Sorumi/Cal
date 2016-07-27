//
//  SRMCalendarTool.m
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarTool.h"

@interface SRMCalendarTool ()



@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;


@end

@implementation SRMCalendarTool

- (NSDate *)date
{
    if (!_date) {
        _date = [NSDate date];
    }
    return _date;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSDateComponents *)components
{
    if (!_components) {
        _components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |NSCalendarUnitWeekday fromDate:self.date];
    }
    return _components;
}

- (NSUInteger)dayCount
{
    NSDate *currentDate = [self.calendar dateFromComponents:self.components];
    NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currentDate];
    return range.length;
}
// Sunday:0 Monday:1 Tuesday:2 Wednesday:3 Thursday:4 Friday:5 Saturday:6
- (NSUInteger)firstWeekDay
{
    NSDateComponents *firstDayComp = self.components;
    firstDayComp.day = 1;
    NSDate *firstDateInMonth = [self.calendar dateFromComponents:self.components];
    firstDayComp = [self.calendar components:NSCalendarUnitWeekday fromDate:firstDateInMonth];
    return firstDayComp.weekday-1;
}


@end
