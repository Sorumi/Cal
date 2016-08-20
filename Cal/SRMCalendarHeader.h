//
//  SRMMonthHeaderView.h
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMCalendarFrontHeader : UIView

@property (nonatomic) BOOL isFull;

@property (nonatomic, weak) IBOutlet UIView* monthHeader;
@property (nonatomic, weak) IBOutlet UIView* weekHeader;

- (void)setMonthHeaderYear:(NSInteger)year month:(NSInteger)month;
- (void)setWeekHeaderYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day weekday:(NSInteger)weekday;


@property (nonatomic, strong) UIColor *headerTextColorNormal;
@property (nonatomic, strong) UIColor *headerTextColorFull;

- (void)updateTheme;

@end


@interface SRMCalendarBackHeader : UIView

@end