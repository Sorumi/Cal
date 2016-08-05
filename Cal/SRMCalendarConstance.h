//
//  SRMCalendarConstance.h
//  Cal
//
//  Created by Sorumi on 16/7/29.
//  Copyright © 2016年 Sorumi. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

UIKIT_EXTERN CGFloat const SRMHeaderHeight;
UIKIT_EXTERN CGFloat const SRMToolbarHeight;
UIKIT_EXTERN CGFloat const SRMMonthViewWeekdayHeight;
UIKIT_EXTERN CGFloat const SRMWeekViewWeekdayHeight;
UIKIT_EXTERN CGFloat const SRMWeekViewDayCircleRadius;

UIKIT_EXTERN CGFloat const SRMEventCellHeight;
UIKIT_EXTERN CGFloat const SRMTaskCellHeight;
UIKIT_EXTERN CGFloat const SRMItemCellSpacing;

typedef NS_ENUM(NSInteger, SRMCalendarViewMode) {
    SRMCalendarMonthViewMode    = 0,
    SRMCalendarWeekViewMode     = 1,
    SRMCalendarItemViewMode     = 2
};

typedef NS_ENUM(NSInteger, SRMTimeSelectMode) {
    SRMTimeSelectNone   = 0,
    SRMTimeSelectStart  = 1,
    SRMTimeSelectEnd    = 2
};

typedef NS_ENUM(NSInteger, SRMEventRepeatMode) {
    SRMEventRepeatNever         = 0,
    SRMEventRepeatEveryDay      = 1,
    SRMEventRepeatEveryWeek     = 2,
    SRMEventRepeatEveryTwoWeek  = 3,
    SRMEventRepeatEveryMonth    = 4,
    SRMEventRepeatEveryYear     = 5
};