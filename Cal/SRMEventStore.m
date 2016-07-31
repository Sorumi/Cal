//
//  SRMEventStore.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventStore.h"
#import "SRMEvent.h"

@interface SRMEventStore ()

@property (strong, nonatomic) EKEventStore *eventStore;

@property (nonatomic, strong) NSMutableArray<SRMEvent *> *events;
@property (nonatomic, strong) NSArray<EKCalendar *> *calendars;

@end

@implementation SRMEventStore

#pragma mark - Properties

- (NSArray *)allEvents
{
    return self.events;
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

    if (!_events) {
        _events = [[NSMutableArray alloc] init];
    }
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
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

- (void)fetchEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSPredicate *allEventsPredicate = [self.eventStore predicateForEventsWithStartDate:fromDate endDate:toDate calendars:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *systemEvents = [self.eventStore eventsMatchingPredicate:allEventsPredicate];

        if (systemEvents != nil) {
            for (EKEvent* event in systemEvents) {
                [self addSystemEvent:event];
            }
        }
    });
    
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

- (void)addSystemEvent:(EKEvent *)systemEvent;
{
    SRMEvent *event = [[SRMEvent alloc] initWithSystemEvent:systemEvent];
    [self.events addObject:event];

}




@end
