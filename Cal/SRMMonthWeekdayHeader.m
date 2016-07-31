//
//  SRMWeekdayHeader.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthWeekdayHeader.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarAppearance.h"

@interface SRMMonthWeekdayHeader ()

@property (nonatomic, strong) NSArray *weekday;

@end

@implementation SRMMonthWeekdayHeader

- (void)awakeFromNib
{
    // weekday labels
    
    SRMCalendarAppearance *appearance = [[SRMCalendarAppearance alloc] init];
    
    self.weekday = @[@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT"];
    
    int width = [UIScreen mainScreen].bounds.size.width/7;
    
    CGRect labelRect = CGRectMake(0, 0, width, SRMMonthViewWeekdayHeight);
    
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        label.text = self.weekday[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = appearance.monthWeekdayFontColor;
        label.font = [UIFont fontWithName:@"Avenir" size:14];
        [self addSubview:label];
        labelRect.origin.x += width;
    }

}

@end
