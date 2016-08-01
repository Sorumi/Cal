//
//  SRMWeekDayCell.m
//  Cal
//
//  Created by Sorumi on 16/7/29.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMWeekDayCell.h"
#import "SRMCalendarAppearance.h"

@implementation SRMWeekDayCell

- (void)awakeFromNib
{
}

- (void)setWeekDate:(NSInteger)day
{
    self.dateLabel.text = [NSString stringWithFormat:@"%lu", day];
//    self.dateLabel.textColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"WeekViewDateFontColor"];
}

@end
