//
//  SRMWeekDayCell.m
//  Cal
//
//  Created by Sorumi on 16/7/29.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMWeekDayCell.h"

@implementation SRMWeekDayCell

- (void)awakeFromNib
{
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.3;
}

- (void)setWeekDate:(NSInteger)day
{
    self.dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    self.dateLabel.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
}

@end
