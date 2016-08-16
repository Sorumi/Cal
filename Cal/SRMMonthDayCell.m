//
//  SRMMonthDayCell.m
//  Cal
//
//  Created by Sorumi on 16/7/24.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthDayCell.h"
#import "SRMCalendarAppearance.h"

@interface SRMMonthDayCell ()

//@property (weak, nonatomic) IBOutlet SRMMonthDayTriangleView *triangleView;

@end

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

- (void)setToday:(BOOL)isToday
{
//    self.triangleView.backgroundColor = isToday ? [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"CalendarMonthBorderColor"] : nil;
}


@end

@implementation SRMMonthDayTriangleView

- (void)awakeFromNib
{
//    self.backgroundColor = [UIColor redColor];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [path closePath];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    
    self.layer.mask = mask;
}

@end