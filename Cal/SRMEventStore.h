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

+ (instancetype)sharedStore;

- (void)checkCalendarAuthorizationStatus;

- (void)fetchRecentEvents:(NSDate *)fromDate;
- (void)fetchDayEvents:(NSDate *)date;
- (NSArray *)dayEvents:(NSDate *)date;

- (BOOL)addEvent:(NSString *)title calendar:(NSInteger)calendar allDay:(BOOL)allday startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
