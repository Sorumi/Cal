//
//  SRMMonthHeaderView.m
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SRMCalendarHeader.h"

@interface SRMCalendarHeader ()

@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *weekArray;

@property (nonatomic, weak) IBOutlet UILabel *monthViewYearLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthViewMonthLabel;

@property (nonatomic, weak) IBOutlet UILabel *weekViewDayLable;
@property (nonatomic, weak) IBOutlet UILabel *weekViewMonthYearLable;
@property (nonatomic, weak) IBOutlet UILabel *weekViewWeekdayLable;

@end

@implementation SRMCalendarHeader


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.monthArray = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    self.weekArray = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    
    CALayer *layer =  self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.5;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setMonthHeaderYear:(NSInteger)year month:(NSInteger)month
{
    self.monthViewYearLabel.text = [NSString stringWithFormat:@"%lu", year];
    self.monthViewMonthLabel.text = self.monthArray[month-1];
}

- (void)setWeekHeaderYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day weekday:(NSInteger)weekday
{
    self.weekViewDayLable.text = [NSString stringWithFormat:@"%lu", day];
    self.weekViewMonthYearLable.text = [[NSString stringWithFormat:@"%lu ", year] stringByAppendingString:self.monthArray[month-1]];
    self.weekViewWeekdayLable.text = self.weekArray[weekday];
}


@end
