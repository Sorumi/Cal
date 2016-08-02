//
//  SRMEventCell.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "SRMEvent.h"
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

- (void)setEvent:(SRMEvent *)event
{
    SRMCalendarTool *tool = [[SRMCalendarTool alloc] init];
    
    EKEvent *systemEvent = event.systemEvent;
    self.titleLable.text = systemEvent.title;
    self.categoryColorView.backgroundColor = [UIColor colorWithCGColor:systemEvent.calendar.CGColor];
    
    if (!systemEvent.allDay) {
        self.dateLabel.hidden = NO;
        self.dateLabel.text = [tool dateFormat:systemEvent.startDate];
        
        NSInteger hour = [tool hoursFromDate:systemEvent.startDate toDate:systemEvent.endDate];
        NSInteger minute = [tool minutesFromDate:systemEvent.startDate toDate:systemEvent.endDate];
        NSString *hourStr = hour == 0 ? @"" : [NSString stringWithFormat:@"%luh", hour];
        NSString *minuteStr = minute == 0 ? @"" : [NSString stringWithFormat:@"%lum", minute];
        self.durationLabel.text = [hourStr stringByAppendingString:minuteStr];
        
    } else {
        self.dateLabel.hidden = YES;
        self.timeLabel.text = [tool dateFormat:systemEvent.startDate];
        NSInteger day = [tool daysFromDate:systemEvent.startDate toDate:systemEvent.endDate] + 1;
        self.durationLabel.text = [NSString stringWithFormat:@"%lud", day];
    }
    
    
}


@end
