//
//  SRMMonthDayCell.m
//  Cal
//
//  Created by Sorumi on 16/7/24.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthDayCell.h"
#import "SRMThemeStore.h"
#import "SRMCalendarTool.h"

@interface SRMMonthDayCell ()

@property (weak, nonatomic) IBOutlet SRMMonthDayTriangleView *triangleView;

@end

@implementation SRMMonthDayCell

- (void)awakeFromNib
{

}

- (void)setCurrentMonthDate:(NSInteger)day
{
    _dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    _dateLabel.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
}

- (void)setOtherMonthDate:(NSInteger)day
{
    _dateLabel.text = [NSString stringWithFormat:@"%lu", day];
    _dateLabel.textColor = [UIColor lightGrayColor];
}

- (void)setToday
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    NSDictionary *theme = [[SRMThemeStore sharedStore] monthThemesForYear:[tool yearOfDate:_date] month:[tool monthOfDate:_date]];
    
    _triangleView.backgroundColor = [[SRMThemeStore sharedStore] colorOfTheme:theme forName:@"MonthTodayTriangleColor"];
}

- (void)setEvent
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    NSDictionary *theme = [[SRMThemeStore sharedStore] monthThemesForYear:[tool yearOfDate:_date] month:[tool monthOfDate:_date]];
    
    _triangleView.backgroundColor = [[SRMThemeStore sharedStore] colorOfTheme:theme forName:@"MonthEventTriangleColor"];
    
}

- (void)setClear
{
    _triangleView.backgroundColor = nil;
}

@end

@implementation SRMMonthDayTriangleView

- (void)awakeFromNib
{
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