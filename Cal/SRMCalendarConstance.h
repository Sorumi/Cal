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

UIKIT_EXTERN CGFloat const SRMDayHeaderHeight;
UIKIT_EXTERN CGFloat const SRMDayBoardCellHeight;

typedef NS_ENUM(NSInteger, SRMCalendarViewMode) {
    SRMCalendarMonthViewMode    = 0,
    SRMCalendarWeekViewMode     = 1,
    SRMCalendarItemViewMode     = 2,
    SRMCalendarEditViewMode     = 3,
    SRMCalendarHeaderViewMode   = 4
};

typedef NS_ENUM(NSInteger, SRMAppearanceEditMode) {
    SRMAppearanceEditStampMode  = 1,
    SRMAppearanceEditThemeMode  = 2
};

typedef NS_ENUM(NSInteger, SRMTimeSelectMode) {
    SRMTimeSelectNone   = 0,
    SRMTimeSelectStart  = 1,
    SRMTimeSelectEnd    = 2
};

typedef NS_ENUM(NSInteger, SRMEventSelectMode) {
    SRMEventSelectCalendar  = 0,
    SRMEventSelectRepeat    = 1,
    SRMEventSelectRepeatEnd = 2,
    SRMEventSelectReminder  = 3,
};

typedef NS_ENUM(NSInteger, SRMEventRepeatMode) {
    SRMEventRepeatNever         = 0,
    SRMEventRepeatEveryDay      = 1,
    SRMEventRepeatEveryWeek     = 2,
    SRMEventRepeatEveryTwoWeek  = 3,
    SRMEventRepeatEveryMonth    = 4,
    SRMEventRepeatEveryYear     = 5
};

typedef NS_ENUM(NSInteger, SRMEventReminderMode) {
    SRMEventReminderNone   = 0,
    SRMEventReminderNADOnTime   = 1,
    SRMEventReminderNADFiveMin   = 2,
    SRMEventReminderNADFifteenMin   = 3,
    SRMEventReminderNADThirtyMin   = 4,
    SRMEventReminderNADOneHour   = 5,
    SRMEventReminderNADOneDay   = 6,
    
    SRMEventReminderADOnDay   = 1,
    SRMEventReminderADOneDay   = 2,
    SRMEventReminderADTwoDay   = 3,
    SRMEventReminderADOneWeek   = 4,
};







