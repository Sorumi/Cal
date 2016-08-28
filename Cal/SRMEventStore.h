//
//  SRMEventStore.h
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@protocol SRMEventStoreDelegate <NSObject>

@optional
- (void)didFetchRecentEvent;
- (void)didFetchDayEvent;

@end

@interface SRMEventStore : NSObject

@property (nonatomic, weak) id<SRMEventStoreDelegate> delegate;
@property (nonatomic) BOOL isGranted;
@property (nonatomic, readonly) NSArray *recentEvents;
@property (nonatomic, readonly) NSArray<EKCalendar *> *allCalendars;

+ (instancetype)sharedStore;

- (void)checkCalendarAuthorizationStatus;

- (void)fetchRecentEvents:(NSDate *)fromDate;
- (void)fetchDayEvents:(NSDate *)date;
- (NSArray *)dayEvents:(NSDate *)date;
- (NSArray *)dayEventsAllDay:(NSDate *)date;
- (NSArray *)dayEventsNotAllDay:(NSDate *)date;

- (BOOL)addEvent:(NSString *)title calendar:(NSInteger)calendar allDay:(BOOL)allday startDate:(NSDate *)startDate endDate:(NSDate *)endDate location:(NSString *)location note:(NSString *)note recurrenceRule:(EKRecurrenceRule *)rule alarm:(EKAlarm *)alarm icon:(NSInteger)icon;
- (BOOL)deleteEvent:(NSString *)eventIdentifier;

- (NSInteger)defaultCalendarIndex;

- (NSInteger)iconForEventIdentifier:(NSString *)eventIdentifier;
- (void)setColor:(NSInteger)colorNum forCalendarIdentifier:(NSString *)calendarIdentifier;
- (NSInteger)colorForCalendarIdentifier:(NSString *)calendarIdentifier;
- (void)setColor:(NSInteger)colorNum forCalendarIndex:(NSInteger)calendarIndex;
- (NSInteger)colorForCalendarIndex:(NSInteger)calendarIndex;

- (BOOL)saveChanges;

@end
