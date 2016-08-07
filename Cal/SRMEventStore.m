//
//  SRMEventStore.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventStore.h"
//#import "SRMEvent.h"
#import "SRMCalendarTool.h"

@interface SRMEventStore ()

@property (nonatomic, strong) EKEventStore *eventStore;

@property (nonatomic, strong) NSArray<EKEvent *> *privateEvents;

@property (nonatomic, strong) NSMutableDictionary *dayEvents;

@property (nonatomic, strong) NSArray<EKCalendar *> *calendars;

@property (nonatomic, strong) NSMutableDictionary *iconDictionary;

@end

@implementation SRMEventStore

#pragma mark - Properties

- (NSArray *)recentEvents
{
    return self.privateEvents;
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
    if (!_dayEvents) {
        _dayEvents = [[NSMutableDictionary alloc] init];
    }
    NSString *path = [self itemArchivePath];
    _iconDictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
//    for (NSString *key in _iconDictionary) {
//        NSString *value = _iconDictionary[key];
//        NSLog(@"%@", value);
//    }
    
    if (!_iconDictionary) {
        _iconDictionary = [[NSMutableDictionary alloc] init];
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
    NSDate *endDate = [[SRMCalendarTool tool] dateByAddingMonths:1 toDate:fromDate];
    
    NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:fromDate
                                                                               endDate:endDate
                                                                             calendars:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
        
        if (systemEvents != nil) {
            for (EKEvent* event in systemEvents) {
                if (![self iconForEventIdentifier:event.eventIdentifier]) {
                    [self setIcon:0 forEventIdentifier:event.eventIdentifier];
                }
            }
            [self saveChanges];
            self.privateEvents = systemEvents;
        }
        dispatch_async(dispatch_get_main_queue(), ^{

            [self.delegate didFetchRecentEvent];
        });
    });

}

- (void)fetchDayEvents:(NSDate *)date
{
    NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:date
                                                                               endDate:date
                                                                             calendars:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
        
        if (systemEvents != nil) {
            for (EKEvent* event in systemEvents) {
                if (![self iconForEventIdentifier:event.eventIdentifier]) {
                    [self setIcon:0 forEventIdentifier:event.eventIdentifier];
                }
            }
            [self saveChanges];
            self.dayEvents[[[SRMCalendarTool tool] dateFormat:date]] = systemEvents;
        }
        
    });
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

#pragma mark - File

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"item.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.iconDictionary toFile:path];
}

#pragma mark - Private

- (void)requestAccessToCalendar
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                    completion:^(BOOL granted, NSError *error){
                                        if (granted) {
                                            self.isGranted = YES;
                                            self.calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
                                        } else {
                                            self.isGranted = NO;
                                            NSLog(@"Access not granted: %@", error);
                                            // tell user!
                                        }
                                    }];
}

//- (void)fetchEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
//{
//    NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:fromDate endDate:toDate calendars:nil];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];
//        
//        if (systemEvents != nil) {
//            for (EKEvent* event in systemEvents) {
//                //                [self addSystemEvent:event];
//                if (![self iconForEventIdentifier:event.eventIdentifier]) {
//                    [self setIcon:0 forEventIdentifier:event.eventIdentifier];
//                }
//            }
//        }
//        
//    });
//    
//}

//- (void)addEvent:(EKEvent *)event;
//{
//    SRMEvent *event = [[SRMEvent alloc] initWithSystemEvent:systemEvent];
////    systemEvent.recurrenceRules[0].
//    
//    [self.events addObject:event];
//
//}

- (BOOL)addEvent:(NSString *)title calendar:(NSInteger)calendar allDay:(BOOL)allday startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    EKEvent *event  = [EKEvent eventWithEventStore:self.eventStore];
    [event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
    event.title = title;
    event.allDay = allday;
    event.startDate = startDate;
    event.endDate = endDate;
    
    return [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
}



@end
