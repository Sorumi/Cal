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

@interface SRMMonthBackground : UIView

@end

@implementation SRMMonthBackground

- (void)awakeFromNib
{
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
}

@end


@interface SRMMonthWeekdayHeader ()

@property (nonatomic, strong) NSArray *weekday;

@end

@implementation SRMMonthWeekdayHeader

- (void)awakeFromNib
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width/7;
    
    // weekday labels
    
    self.weekday = @[@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT"];
    
    CGRect labelRect = CGRectMake(0, 0, width, SRMMonthViewWeekdayHeight);
    
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        label.text = self.weekday[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"MonthViewWeekdayFontColor"];
        label.font = [UIFont fontWithName:@"Avenir" size:14];
        [self addSubview:label];
        labelRect.origin.x += width;
    }

}

@end

