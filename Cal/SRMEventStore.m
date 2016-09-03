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

@property (nonatomic, strong) NSArray<EKEvent *> *privateRecentEvents;
@property (nonatomic, strong) NSMutableDictionary *privateDayEvents;


@property (nonatomic, strong) NSArray<EKCalendar *> *calendars;

@property (nonatomic, strong) NSMutableDictionary *iconDictionary;
@property (nonatomic, strong) NSMutableDictionary *colorDictionary;

@end

@implementation SRMEventStore

#pragma mark - Properties

- (NSArray *)recentEvents
{
    NSArray *sortedArray = [self.privateRecentEvents sortedArrayUsingComparator:^NSComparisonResult(EKEvent *event1, EKEvent *event2) {
        return [event1.startDate compare:event2.startDate];
    }];;
    return sortedArray;
}

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
    NSString *iconPath = [self iconArchivePath];
    _iconDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:iconPath];
    
    NSString *colorPath = [self colorArchivePath];
    _colorDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:colorPath];
    
//    for (NSString *key in _iconDictionary) {
//        NSString *value = _iconDictionary[key];
//        NSLog(@"%@", value);
//    }
    
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

- (void)fetchRecentEvents:(NSDate *)fromDate
{
    if (!self.isGranted) {
        return;
    }
    NSDate *endDate = [[SRMCalendarTool tool] dateByAddingMonths:1 toDate:fromDate];
    
    NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:fromDate
                                                                               endDate:endDate
                                                                             calendars:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
        
        for (EKEvent* event in systemEvents) {
            if (![self iconForEventIdentifier:event.eventIdentifier]) {
                [self setIcon:0 forEventIdentifier:event.eventIdentifier];
            }
            
            //                NSLog(@"%@ %@", event.title, event.eventIdentifier);
        }
        [self saveChanges];
        self.privateRecentEvents = systemEvents;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.delegate didFetchRecentEvent];
        });
    });

}

- (void)fetchDaysEventsInMonth:(NSDate *)date
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDate *startDate = [tool beginningOfMonthOfDate:date];
        NSInteger days = [tool dayCountOfMonthofDate:startDate];
        
        for (int i=1; i<=days; i++) {
            
            NSDate *endDate = [tool dateByAddingDays:1 toDate:startDate];
            
            NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                                       endDate:endDate
                                                                                     calendars:nil];
            
            
            
            NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
            
            self.privateDayEvents[[[SRMCalendarTool tool] dateFormat:startDate]] = systemEvents;
            
            startDate = [[SRMCalendarTool tool] dateByAddingDays:1 toDate:startDate];
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFetchDaysEventInMonth];
        });
    });
}


//- (void)fetchDaysEventsInThreeMonths:(NSDate *)date
//{
//    SRMCalendarTool *tool = [SRMCalendarTool tool];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSDate *startDate = [tool beginningOfMonthOfDate:date];
//        NSInteger days = [tool dayCountOfMonthofDate:startDate];
//        
//        for (int i=1; i<=days; i++) {
//            
//            NSDate *endDate = [tool dateByAddingDays:1 toDate:startDate];
//            
//            NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:startDate
//                                                                                       endDate:endDate
//                                                                                     calendars:nil];
//            
//            
//            
//            NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
//            
//            self.privateDayEvents[[[SRMCalendarTool tool] dateFormat:startDate]] = systemEvents;
//            
//            startDate = [[SRMCalendarTool tool] dateByAddingDays:1 toDate:startDate];
//        }
//        
//        startDate = [tool dateByAddingMonths:-1 toDate:[tool beginningOfMonthOfDate:date]];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.delegate didFetchDaysEventInMonth];
//        });
//    });
//}

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

        for (EKEvent* event in systemEvents) {
            if (![self iconForEventIdentifier:event.eventIdentifier]) {
                [self setIcon:0 forEventIdentifier:event.eventIdentifier];
            }
        }
        [self saveChanges];
        self.privateDayEvents[[[SRMCalendarTool tool] dateFormat:date]] = systemEvents;

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.delegate didFetchDayEvent];
        });
        
    });
}

- (NSArray *)dayEvents:(NSDate *)date
{
    NSArray *sortedArray = [self.privateDayEvents[[[SRMCalendarTool tool] dateFormat:date]] sortedArrayUsingComparator:^NSComparisonResult(EKEvent *event1, EKEvent *event2) {
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

- (BOOL)editEvent:(EKEvent *)event title:(NSString *)title calendar:(NSInteger)calendar allDay:(BOOL)allday startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location note:(NSString *)note recurrenceRule:(EKRecurrenceRule *)rule alarm:(EKAlarm *)alarm icon:(NSInteger)icon
{
    
//    EKEvent *event = [store eventWithIdentifier:savedEventId];
    // Uncomment below if you want to create a new event if savedEventId no longer exists
    // if (event == nil)
    //   event = [EKEvent eventWithEventStore:store];
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
    }
    if (alarm) {
        [event addAlarm:alarm];
    }

    if ([self.eventStore saveEvent:event span:EKSpanFutureEvents commit:YES error:nil]) {
        [self setIcon:icon forEventIdentifier:event.eventIdentifier];
        [self saveChanges];
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

- (BOOL)saveChanges
{
    NSString *iconPath = [self iconArchivePath];
    NSString *colorPath = [self colorArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.iconDictionary toFile:iconPath] && [NSKeyedArchiver archiveRootObject:self.colorDictionary toFile:colorPath];
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
        [self saveChanges];
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

@end
