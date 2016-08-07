//
//  SRMEventCell.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <EventKit/EventKit.h>
//#import "SRMEvent.h"
#import "SRMEventCell.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarTool.h"

@interface SRMEventCell ()

@property (nonatomic) IBOutlet UIView *blockView;
@property (nonatomic) IBOutlet UIView *categoryColorView;
@property (nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation SRMEventCell

- (void)awakeFromNib {
    // Initialization code

    // shadow
    CALayer *layer = self.blockView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Public

- (void)setEvent:(EKEvent *)event
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
//    EKEvent *systemEvent = event.systemEvent;
    self.titleLable.text = event.title;
    self.categoryColorView.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
    
    if (!event.allDay) {
        self.dateLabel.hidden = NO;
        self.dateLabel.text = [tool dateFormat:event.startDate];
        self.timeLabel.text = [tool timeFormat:event.startDate];
        
        NSInteger hour = [tool hoursFromDate:event.startDate toDate:event.endDate];
        NSInteger minute = [tool minutesFromDate:event.startDate toDate:event.endDate];
        NSString *hourStr = hour == 0 ? @"" : [NSString stringWithFormat:@"%luh", hour];
        NSString *minuteStr = minute == 0 ? @"" : [NSString stringWithFormat:@"%lum", minute];
        self.durationLabel.text = [hourStr stringByAppendingString:minuteStr];
        
    } else {
        self.dateLabel.hidden = YES;
        self.timeLabel.text = [tool dateFormat:event.startDate];
        NSInteger day = [tool daysFromDate:event.startDate toDate:event.endDate] + 1;
        self.durationLabel.text = [NSString stringWithFormat:@"%lud", day];
    }
    
    
}


@end
