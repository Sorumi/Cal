//
//  SRMCalendarTool.m
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarTool.h"

@interface SRMCalendarTool ()

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateComponents *components;
@property (nonatomic, strong) NSArray *chineseWeekday;

@end

@implementation SRMCalendarTool


#pragma mark - Initialization

+ (instancetype)tool
{
    static SRMCalendarTool *tool = nil;
    
    if (!tool) {
        tool = [[self alloc] initPrivate];
    }
    
    return tool;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMCalendarTool tool]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
    }
    return self;
}

#pragma mark - Properties

- (NSDate *)minimumDate
{
    if (!_minimumDate) {
        _minimumDate = [self dateWithYear:2000 month:1 day:1];
    }
    return _minimumDate;
}

- (NSDate *)maximumDate
{
    if (!_maximumDate) {
        _maximumDate = [self dateWithYear:2030 month:12 day:31];
    }
    return _maximumDate;
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
        _components = [[NSDateComponents alloc] init];
    }
    return _components;
}

- (NSArray *)chineseWeekday
{
    if (!_chineseWeekday) {
        _chineseWeekday = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
    }
    return _chineseWeekday;
}

#pragma mark -

- (NSInteger)yearOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitYear fromDate:date];
    return component.year;
}

- (NSInteger)monthOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitMonth
                                                   fromDate:date];
    return component.month;
}

- (NSInteger)dayOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitDay
                                                   fromDate:date];
    return component.day;
}
// Sunday:0 Monday:1 Tuesday:2 Wednesday:3 Thursday:4 Friday:5 Saturday:6
- (NSInteger)weekdayOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    return component.weekday - 1;
}

- (NSInteger)weekOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitWeekOfYear fromDate:date];
    return component.weekOfYear;
}

- (NSInteger)hourOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitHour
                                                   fromDate:date];
    return component.hour;
}

- (NSInteger)miniuteOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitMinute
                                                   fromDate:date];
    return component.minute;
}

- (NSInteger)secondOfDate:(NSDate *)date
{
    NSDateComponents *component = [self.calendar components:NSCalendarUnitSecond
                                                   fromDate:date];
    return component.second;
}

#pragma mark -

- (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSDateComponents *components = self.components;
    components.year = year;
    components.month = month;
    components.day = day;
    components.hour = 0;
    NSDate *date = [self.calendar dateFromComponents:components];
    components.year = NSIntegerMax;
    components.month = NSIntegerMax;
    components.day = NSIntegerMax;
    components.hour = NSIntegerMax;
    return date;
}

#pragma mark -

- (NSInteger)monthsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.month;
}

- (NSInteger)weeksFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitWeekOfYear
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.weekOfYear;
}

- (NSInteger)daysFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.day;
}

- (NSInteger)hoursFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitHour
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.hour;
}

- (NSInteger)minutesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitHour | NSCalendarUnitMinute
                                                    fromDate:fromDate
                                                      toDate:toDate
                                                     options:0];
    return components.minute;
}

#pragma mark - Adding

- (NSDate *)dateByAddingYears:(NSInteger)years toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.year = years;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.year = NSIntegerMax;
    return d;
}

- (NSDate *)dateByAddingMonths:(NSInteger)months toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.month = months;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.month = NSIntegerMax;
    return d;
}

- (NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.weekOfYear = weeks;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.weekOfYear = NSIntegerMax;
    return d;
}

- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.day = days;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.day = NSIntegerMax;
    return d;
}

- (NSDate *)dateByAddingHours:(NSInteger)hours toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.hour = hours;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.hour = NSIntegerMax;
    return d;
}

- (NSDate *)dateByAddingMinutes:(NSInteger)minutes toDate:(NSDate *)date
{
    NSDateComponents *components = self.components;
    components.minute = minutes;
    NSDate *d = [self.calendar dateByAddingComponents:components toDate:date options:0];
    components.minute = NSIntegerMax;
    return d;
}

#pragma mrak -

- (NSDate *)dateByIgnoringTimeComponentsOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [self.calendar dateFromComponents:components];
}

- (NSInteger)dayCountOfMonthofDate:(NSDate *)date
{
    NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

- (NSDate *)beginningOfMonthOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.day = 1;
    return [self.calendar dateFromComponents:components];
}

- (NSDate *)beginningOfWeekOfDate:(NSDate *)date
{
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    NSDateComponents *components = self.components;
    components.day = - (weekdayComponents.weekday - self.calendar.firstWeekday);
    
    components.day = (components.day-7) % 7;
    NSDate *beginningOfWeek = [self.calendar dateByAddingComponents:components toDate:date options:0];
    beginningOfWeek = [self dateByIgnoringTimeComponentsOfDate:beginningOfWeek];
    components.day = NSIntegerMax;
    return beginningOfWeek;
}

- (NSDate *)beginningOfDayOfDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:date];
    components.hour = 0;
    return [self.calendar dateFromComponents:components];
}

- (BOOL)date:(NSDate *)date1 isEqualToDate:(NSDate *)date2
{
    NSInteger year1 = [self yearOfDate:date1];
    NSInteger month1 = [self monthOfDate:date1];
    NSInteger day1 = [self  dayOfDate:date1];
    
    NSInteger year2 = [self yearOfDate:date2];
    NSInteger month2 = [self monthOfDate:date2];
    NSInteger day2 = [self  dayOfDate:date2];
    
    if (year1 == year2 && month1 == month2 && day1 == day2) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)dateAndTimeFormat:(NSDate *)date
{
//    NSLog(@"[[NSTimeZone localTimeZone] name] is %@",[[NSTimeZone localTimeZone] name]);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-d HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

////
- (NSString *)dateStoreFormat:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-d"];
    return [formatter stringFromDate:date];
}

- (NSString *)dateDisplayFormat:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    if ([NSLocalizedString(@"local", nil) isEqual: @"en"]) {
        [formatter setDateFormat:@"d MMM YYYY"];
        
    } else if ([NSLocalizedString(@"local", nil) isEqual: @"cs"]) {
        [formatter setDateFormat:@"YYYY年M月d日"];
    }
    
    return [formatter stringFromDate:date];
}

- (NSString *)timeDisplayFormat:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"HH:mm"];

    return [formatter stringFromDate:date];
}

- (NSString *)weekdayDisplayFormat:(NSDate *)date
{

    if ([NSLocalizedString(@"local", nil) isEqual: @"cs"]) {
        return self.chineseWeekday[[self weekdayOfDate:date]];
        
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE"];
        return [formatter stringFromDate:date];
    }
    
}

- (NSDate *)dateOnHour:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:date];
    
    components.minute = 0;
    components.second = 0;
    NSDate *result = [self.calendar dateFromComponents:components];
    return result;
}

- (NSDate *)date:(NSDate *)date onDefiniteHour:(NSInteger)hour
{
    NSDate *result = [self.calendar dateBySettingHour:hour
                                               minute:0
                                               second:0
                                               ofDate:date
                                              options:0];
    return result;
}

@end
