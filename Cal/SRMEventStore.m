//
//  SRMEventStore.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventStore.h"
#import "SRMCalendarTool.h"

@interface SRMEventStore ()

@property (nonatomic, strong) EKEventStore *eventStore;

@property (nonatomic, strong) NSMutableDictionary *privateDayEvents;
@property (nonatomic, strong) NSMutableDictionary *privateMonthEvents;

@property (nonatomic, strong) NSArray<EKCalendar *> *calendars;

@property (nonatomic, strong) NSMutableDictionary *iconDictionary;
@property (nonatomic, strong) NSMutableDictionary *colorDictionary;

@end

@implementation SRMEventStore

#pragma mark - Properties

- (NSArray<EKCalendar *> *)allCalendars
{
    return self.calendars;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMEventStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMEventStore sharedStore]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];

    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    if (!_privateDayEvents) {
        _privateDayEvents = [[NSMutableDictionary alloc] init];
    }
    if (!_privateMonthEvents) {
        _privateMonthEvents = [[NSMutableDictionary alloc] init];
    }
    NSString *iconPath = [self iconArchivePath];
    _iconDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:iconPath];
    
    NSString *colorPath = [self colorArchivePath];
    _colorDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:colorPath];
    
    if (!_iconDictionary) {
        _iconDictionary = [[NSMutableDictionary alloc] init];
    }
    if (!_colorDictionary) {
        _colorDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Public

- (void)checkCalendarAuthorizationStatus
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
            [self requestAccessToCalendar];
            break;
            
        case EKAuthorizationStatusAuthorized:
            self.isGranted = YES;
            self.calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
            [self setCalendarsColor];
            break;
            
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            self.isGranted = NO;
            // tell user!
            break;
    }
}

- (void)fetchDaysEventsInMonth:(NSDate *)date
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        [self getDaysEventInMonth:date];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"didFetchMonth %@ %lu", [[SRMCalendarTool tool] dateAndTimeFormat:date], [self monthEvents:date].count);
            [self.delegate didFetchDaysEventInMonth];
        });
    });
}

- (void)fetchDaysEventsInThreeMonths:(NSDate *)midDate
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self getDaysEventInMonth:midDate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"didFetchThreeMonths %@ %lu", [[SRMCalendarTool tool] dateAndTimeFormat:midDate], [self monthEvents:midDate].count);
            [self.delegate didFetchDaysEventInMonth];
        });

        NSDate *prevMonth = [[SRMCalendarTool tool] dateByAddingMonths:-1 toDate:midDate];
        [self getDaysEventInMonth:prevMonth];
        NSDate *nextMonth = [[SRMCalendarTool tool] dateByAddingMonths:1 toDate:midDate];
        [self getDaysEventInMonth:nextMonth];
    });

}

- (void)fetchDayEvents:(NSDate *)date
{
    if (!self.isGranted) {
        return;
    }
    NSDate *fromDate = [[SRMCalendarTool tool] beginningOfDayOfDate:date];
    NSDate *toDate = [[SRMCalendarTool tool] dateByAddingDays:1 toDate:fromDate];
    NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:fromDate
                                                                               endDate:toDate
                                                                             calendars:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];

        if (systemEvents) {
            for (EKEvent* event in systemEvents) {
                if (![self iconForEventIdentifier:event.eventIdentifier]) {
                    [self setIcon:0 forEventIdentifier:event.eventIdentifier];
                }
            }
            self.privateDayEvents[[[SRMCalendarTool tool] dateStoreFormat:date]] = systemEvents;
            
        } else {
            [self.privateDayEvents removeObjectForKey:[[SRMCalendarTool tool] dateStoreFormat:date]];
        }
        
        [self saveEventIconChanges];


        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate didFetchDayEvent];
        });
        
    });
}

- (NSArray *)dayEvents:(NSDate *)date
{
    NSArray *sortedArray = [self.privateDayEvents[[[SRMCalendarTool tool] dateStoreFormat:date]] sortedArrayUsingComparator:^NSComparisonResult(EKEvent *event1, EKEvent *event2) {
        return [event1.startDate compare:event2.startDate];
    }];;
    return sortedArray;
}

- (NSArray *)dayEventsAllDay:(NSDate *)date
{
    NSMutableArray *allDayEvents = [[NSMutableArray alloc] init];
    NSArray *dayEvents = [self dayEvents:date];
    
    for (EKEvent *event in dayEvents) {
        if (event.allDay) {
            [allDayEvents addObject:event];
        }
    }
    return allDayEvents;
}

- (NSArray *)dayEventsNotAllDay:(NSDate *)date
{
    NSMutableArray *notAllDayEvents = [[NSMutableArray alloc] init];
    NSArray *dayEvents = [self dayEvents:date];
    
    for (EKEvent *event in dayEvents) {
        if (!event.allDay) {
            [notAllDayEvents addObject:event];
        }
    }
    return notAllDayEvents;
}

- (NSArray *)monthEvents:(NSDate *)date
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];

    NSArray *sortedArray = [self.privateMonthEvents[[tool monthStoreFormat:date]] sortedArrayUsingComparator:^NSComparisonResult(EKEvent *event1, EKEvent *event2) {
        return [event1.startDate compare:event2.startDate];
    }];
    return sortedArray;
}

- (BOOL)editEvent:(EKEvent *)event title:(NSString *)title calendar:(NSInteger)calendar allDay:(BOOL)allday startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location note:(NSString *)note recurrenceRule:(EKRecurrenceRule *)rule alarm:(EKAlarm *)alarm icon:(NSInteger)icon
{

    if (!event) {
        event  = [EKEvent eventWithEventStore:self.eventStore];
    }

    [event setCalendar:self.calendars[calendar]];
    event.title = title;
    event.allDay = allday;
    event.startDate = startDate;
    event.endDate = endDate;
    event.location = location;
    event.notes = note;
    if (rule) {
        [event addRecurrenceRule:rule];
    } else {
        [event.recurrenceRules enumerateObjectsUsingBlock:^(EKRecurrenceRule *rule, NSUInteger index, BOOL *stop) {
            [event removeRecurrenceRule:rule];
        }];

    }
    if (alarm) {
        [event addAlarm:alarm];
    } else {
        [event.alarms enumerateObjectsUsingBlock:^(EKAlarm *alarm, NSUInteger index, BOOL *stop) {
            [event removeAlarm:alarm];
        }];
    }

    if ([self.eventStore saveEvent:event span:EKSpanFutureEvents commit:YES error:nil]) {
        [self setIcon:icon forEventIdentifier:event.eventIdentifier];
        [self saveEventIconChanges];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)deleteThisEvent:(NSString *)eventIdentifier
{
    EKEvent* event = [self.eventStore eventWithIdentifier:eventIdentifier];
    return [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:nil];
}

- (BOOL)deleteFutureEvent:(NSString *)eventIdentifier
{
    EKEvent* event = [self.eventStore eventWithIdentifier:eventIdentifier];
    return [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:YES error:nil];
}

- (NSInteger)defaultCalendarIndex
{
    return [self.calendars indexOfObject:[_eventStore defaultCalendarForNewEvents]];
}

#pragma mark - Icon

- (void)setIcon:(NSInteger)iconNum forEventIdentifier:(NSString *)eventIdentifier
{
    self.iconDictionary[eventIdentifier] = [NSNumber numberWithInteger:iconNum];
}

- (NSInteger)iconForEventIdentifier:(NSString *)eventIdentifier
{
    return [self.iconDictionary[eventIdentifier] integerValue];
}

#pragma mark - color

- (void)setColor:(NSInteger)colorNum forCalendarIdentifier:(NSString *)calendarIdentifier
{
    self.colorDictionary[calendarIdentifier] = [NSNumber numberWithInteger:colorNum];
}

- (NSInteger)colorForCalendarIdentifier:(NSString *)calendarIdentifier
{
    return [self.colorDictionary[calendarIdentifier] integerValue];
}

- (void)setColor:(NSInteger)colorNum forCalendarIndex:(NSInteger)calendarIndex
{
    EKCalendar *calendar = self.calendars[calendarIndex];
     self.colorDictionary[calendar.calendarIdentifier] = [NSNumber numberWithInteger:colorNum];
}

- (NSInteger)colorForCalendarIndex:(NSInteger)calendarIndex
{
    EKCalendar *calendar = self.calendars[calendarIndex];
    return [self.colorDictionary[calendar.calendarIdentifier] integerValue];
}

#pragma mark - File

- (NSString *)iconArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"eventIcon.archive"];
}

- (NSString *)colorArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"calendarColor.archive"];
}

- (BOOL)saveEventIconChanges
{
    NSString *iconPath = [self iconArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.iconDictionary toFile:iconPath];
}

- (BOOL)saveCalendarColorChanges
{
    NSString *colorPath = [self colorArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.colorDictionary toFile:colorPath];
}


#pragma mark - Private

- (void)setCalendarsColor
{
    if (self.calendars) {
        for (EKCalendar* calendar in self.calendars) {
            if (![self colorForCalendarIdentifier:calendar.calendarIdentifier]) {
                NSInteger index = [self.calendars indexOfObject:calendar];
                [self setColor:index forCalendarIdentifier:calendar.calendarIdentifier];
            }
        }
        [self saveCalendarColorChanges];
    }
}

- (void)requestAccessToCalendar
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError *error){
                                        if (granted) {
                                            self.isGranted = YES;
                                            self.calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
                                            [self setCalendarsColor];
                                        } else {
                                            self.isGranted = NO;
                                            NSLog(@"Access not granted: %@", error);
                                            // tell user!
                                        }
                                    }];
}

- (void)getDaysEventInMonth:(NSDate *)date
{
    @synchronized(self){
        SRMCalendarTool *tool = [[SRMCalendarTool alloc] init];
        
        NSDate *startDate = [tool beginningOfMonthOfDate:date];
        NSInteger days = [tool dayCountOfMonthofDate:startDate];
        
        NSMutableArray *monthEvents = [[NSMutableArray alloc] init];
        
//        NSLog(@"start fetch %@", [[SRMCalendarTool tool] dateAndTimeFormat:startDate]);
        
        for (int i=1; i<=days; i++) {
            
            NSDate *endDate = [tool dateByAddingDays:1 toDate:startDate];
            
            NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                                       endDate:endDate
                                                                                     calendars:nil];
            
            NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
            
//             NSLog(@"%@ %@ %lu", [[SRMCalendarTool tool] dateAndTimeFormat:startDate], [[SRMCalendarTool tool] dateAndTimeFormat:endDate], systemEvents.count);
            
            if (systemEvents) {
                
                [systemEvents enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger index, BOOL *stop){
                    if (![self iconForEventIdentifier:event.eventIdentifier]) {
                        [self setIcon:0 forEventIdentifier:event.eventIdentifier];
                    }
                }];
                
                self.privateDayEvents[[tool dateStoreFormat:startDate]] = systemEvents;
                [monthEvents addObjectsFromArray:systemEvents];
                
            } else {
                [self.privateDayEvents removeObjectForKey:[tool dateStoreFormat:startDate]];
            }
            
            startDate = [tool dateByAddingDays:1 toDate:startDate];
        }
        
//        NSDate *storeDate = [tool beginningOfMonthOfDate:date];
        if (monthEvents) {
            self.privateMonthEvents[[tool monthStoreFormat:date]] = monthEvents;
        } else {
            [self.privateMonthEvents removeObjectForKey:[tool monthStoreFormat:date]];
        }
//        NSLog(@"end fetch %@", [tool monthStoreFormat:date]);
    }
    
}


@end
