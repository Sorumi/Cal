//
//  SRMWeekdayHeader.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthWeekdayHeader.h"
#import "SRMCalendarConstance.h"

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
@property (nonatomic, strong) NSMutableArray<UILabel *> *labels;

@end

@implementation SRMMonthWeekdayHeader

- (void)awakeFromNib
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width/7;
    
    // weekday labels
    
    _weekday = @[@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT"];
    _labels = [[NSMutableArray alloc] init];
    
    
    CGRect labelRect = CGRectMake(0, 0, width, SRMMonthViewWeekdayHeight);
    
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        label.text = self.weekday[i];
        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"MonthViewWeekdayFontColor"];
        label.textColor = [UIColor colorWithWhite:0.4 alpha:1];
        label.font = [UIFont fontWithName:@"Avenir" size:14];
        [_labels addObject:label];
        [self addSubview:label];
        labelRect.origin.x += width;
    }
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor
{
    _weekdayTextColor = weekdayTextColor;
    for (UILabel *label in _labels) {
        label.textColor = weekdayTextColor;
    }
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.duration = 0.5;
    [self.layer addAnimation:transition forKey:nil];
    
    [self setNeedsDisplay];
}


@end

