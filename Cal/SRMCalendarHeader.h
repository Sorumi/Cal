//
//  SRMMonthHeaderView.h
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMCalendarHeader : UIView

@property (nonatomic, weak) IBOutlet UIView* monthHeader;
@property(nonatomic, weak) IBOutlet UIView* weekHeader;

- (void)setMonthHeaderYear:(NSInteger)year month:(NSInteger)month;
- (void)setWeekHeaderYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day weekday:(NSInteger)weekday;

@end
