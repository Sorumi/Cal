//
//  SRMEventStore.h
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface SRMEventStore : NSObject

@property (nonatomic) BOOL isGranted;
@property (nonatomic, readonly) NSArray *allEvents;

+ (instancetype)sharedStore;

- (void)checkCalendarAuthorizationStatus;
- (void)fetchEventsFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

@end
