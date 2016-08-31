//
//  SRMEventCell.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "SRMEventCell.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarTool.h"
#import "SRMEventStore.h"
#import "SRMColorStore.h"
#import "SRMIconStore.h"

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMEventCell ()

@property (nonatomic) IBOutlet UIView *blockView;
@property (nonatomic) IBOutlet UIView *categoryColorView;
@property (nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIStackView *locationStackView;
@property (weak, nonatomic) IBOutlet UILabel *locationIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;


@end

@implementation SRMEventCell

- (void)awakeFromNib {
    // Initialization code

    // shadow
    CALayer *layer = _blockView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    //
    _iconLabel.font = [UIFont iconfontOfSize:20];
    
    _locationIcon.font = [UIFont iconfontOfSize:20];
    _locationIcon.text = [NSString iconfontIconStringForEnum:IFLocation];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public

- (void)setEvent:(EKEvent *)event
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    _titleLable.text = event.title;
    NSInteger colorNum = [[SRMEventStore sharedStore] colorForCalendarIdentifier:event.calendar.calendarIdentifier];
    _categoryColorView.backgroundColor = [[SRMColorStore sharedStore] colorForNum:colorNum];

    NSInteger iconNum = [[SRMEventStore sharedStore] iconForEventIdentifier:event.eventIdentifier];
    _iconLabel.text = [NSString iconfontIconStringForEnum:[[SRMIconStore sharedStore] iconForNum:iconNum]];
    
    if (!event.allDay) {
        _dateLabel.hidden = NO;
        _dateLabel.text = [tool dateFormat:event.startDate];
        _timeLabel.text = [tool timeFormat:event.startDate];
        
        NSInteger hour = [tool hoursFromDate:event.startDate toDate:event.endDate];
        NSInteger minute = [tool minutesFromDate:event.startDate toDate:event.endDate];
        NSString *hourStr = hour == 0 ? @" " : [NSString stringWithFormat:@"%luh", hour];
        NSString *minuteStr = minute == 0 ? @" " : [NSString stringWithFormat:@"%lum", minute];
        _durationLabel.text = [hourStr stringByAppendingString:minuteStr];
        
    } else {
        _dateLabel.hidden = YES;
        _timeLabel.text = [tool dateFormat:event.startDate];
        NSInteger day = [tool daysFromDate:event.startDate toDate:event.endDate] + 1;
        _durationLabel.text = [NSString stringWithFormat:@"%lud", day];
    }
    
    if (![event.location isEqual:@""]) {
        _locationStackView.hidden = NO;
        _locationLabel.text = event.location;
    } else {
        _locationStackView.hidden = YES;
    }
    
}


@end
