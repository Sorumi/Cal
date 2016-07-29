//
//  SRMMonthDayCell.m
//  Cal
//
//  Created by Sorumi on 16/7/24.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthDayCell.h"

@implementation SRMMonthDayCell


- (void)awakeFromNib
{

}

- (void)setCurrentMonthDate:(NSInteger)day
{
    self.dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    self.dateLabel.textColor = [UIColor darkGrayColor];
}

- (void)setOtherMonthDate:(NSInteger)day
{
    self.dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    self.dateLabel.textColor = [UIColor lightGrayColor];
}


@end
