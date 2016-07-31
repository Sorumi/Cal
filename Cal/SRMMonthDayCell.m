//
//  SRMMonthDayCell.m
//  Cal
//
//  Created by Sorumi on 16/7/24.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthDayCell.h"
#import "SRMCalendarAppearance.h"

@implementation SRMMonthDayCell


- (void)awakeFromNib
{
    
    self.layer.borderColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"CalendarMonthBorderColor"].CGColor;
    self.layer.borderWidth = 0.3;
}

- (void)setCurrentMonthDate:(NSInteger)day
{
    self.dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    self.dateLabel.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
}

- (void)setOtherMonthDate:(NSInteger)day
{
    self.dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    self.dateLabel.textColor = [UIColor lightGrayColor];
}


@end
