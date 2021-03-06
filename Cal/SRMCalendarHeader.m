//
//  SRMMonthHeaderView.m
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"
#import "SRMCalendarHeader.h"

@interface SRMCalendarFrontHeader ()

@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *weekArray;

@property (nonatomic, weak) IBOutlet UILabel *monthViewYearLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthViewMonthLabel;
@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;

@property (nonatomic, weak) IBOutlet UILabel *weekViewDayLable;
@property (nonatomic, weak) IBOutlet UILabel *weekViewMonthYearLable;
@property (nonatomic, weak) IBOutlet UILabel *weekViewWeekdayLable;

@end

@implementation SRMCalendarFrontHeader


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _monthArray = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    _weekArray = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    
    _backButton.titleLabel.font = [UIFont iconfontOfSize:20];
    [_backButton setTitle:[NSString iconfontIconStringForEnum:IFArrowLeft] forState:UIControlStateNormal];
    [_backButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    _prevButton.titleLabel.font = [UIFont iconfontOfSize:20];
    [_prevButton setTitle:[NSString iconfontIconStringForEnum:IFArrowLeft] forState:UIControlStateNormal];
    [_prevButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    _nextButton.titleLabel.font = [UIFont iconfontOfSize:20];
    [_nextButton setTitle:[NSString iconfontIconStringForEnum:IFArrowRight] forState:UIControlStateNormal];
    [_nextButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    _monthViewYearLabel.textColor = self.tintColor;
    _monthViewMonthLabel.textColor = self.tintColor;
}

- (void)tintColorDidChange
{
    _monthViewYearLabel.textColor = self.tintColor;
    _monthViewMonthLabel.textColor = self.tintColor;
    [_prevButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    [_nextButton setTitleColor:self.tintColor forState:UIControlStateNormal];
    [_backButton setTitleColor:self.tintColor forState:UIControlStateNormal];
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

#pragma mark - Theme

- (void)updateTheme
{
    self.tintColor = _isFull ? _headerTextColorFull : _headerTextColorNormal;
    [self setNeedsDisplay];
}

@end


@interface SRMCalendarBackHeader ()

@end

@implementation SRMCalendarBackHeader
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.5;
}

@end





