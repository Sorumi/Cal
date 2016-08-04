//
//  SRMWeekWeekdayHeader.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMWeekWeekdayHeader.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarAppearance.h"

@interface SRMWeekWeekdayHeader ()

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic, strong) NSArray *weekday;

@property (nonatomic) UIView *dayCircle;

@end

@implementation SRMWeekWeekdayHeader

- (void)awakeFromNib
{
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    // weekday labels
    
    self.weekday = @[@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT"];
    
    self.width = [UIScreen mainScreen].bounds.size.width/7;
    CGFloat width = self.width;
    
    CGRect labelRect = CGRectMake(0, 0, width, SRMWeekViewWeekdayHeight);
    
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        label.text = self.weekday[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"WeekViewWeekdayFontColor"];
        label.font = [UIFont fontWithName:@"Avenir" size:10];
        [self addSubview:label];
        labelRect.origin.x += width;
    }
    
    // day circle
    self.dayCircle = [[UIView alloc] initWithFrame:CGRectMake(width/2 - SRMWeekViewDayCircleRadius,
                                                              width/2 - SRMWeekViewDayCircleRadius + 7,
                                                              SRMWeekViewDayCircleRadius*2,
                                                              SRMWeekViewDayCircleRadius*2)];
    self.dayCircle.layer.cornerRadius = SRMWeekViewDayCircleRadius;
    self.dayCircle.backgroundColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"WeekViewDayCircleColor"];
    [self addSubview:self.dayCircle];
}

- (void)setCirclePos:(NSInteger)weekday animated:(BOOL)animated
{

    CGRect newFrame = self.dayCircle.frame;
    newFrame.origin.x = self.width/2 - SRMWeekViewDayCircleRadius + self.width * weekday;
    if (self.dayCircle.frame.origin.x == newFrame.origin.x) {
        return;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.dayCircle.frame = newFrame;
                         }];
    } else {
        self.dayCircle.frame = newFrame;
    }
}


@end
