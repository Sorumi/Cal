//
//  SRMDayScheduleCell.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "SRMDayScheduleCell.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarTool.h"
#import "SRMEventStore.h"
#import "SRMColorStore.h"
#import "SRMIconStore.h"

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMDayScheduleCell ()

@property (nonatomic) IBOutlet UIView *categoryColorView;
@property (nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIStackView *locationStackView;
@property (weak, nonatomic) IBOutlet UILabel *locationIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation SRMDayScheduleCell

- (void)awakeFromNib {
    // Initialization code
    
    // shadow
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    //
    _iconLabel.font = [UIFont iconfontOfSize:20];
    
    _locationIcon.font = [UIFont iconfontOfSize:20];
    _locationIcon.text = [NSString iconfontIconStringForEnum:IFLocation];
}

- (void)setEvent:(EKEvent *)event
{
    _titleLable.text = event.title;
    NSInteger colorNum = [[SRMEventStore sharedStore] colorForCalendarIdentifier:event.calendar.calendarIdentifier];
    _categoryColorView.backgroundColor = [[SRMColorStore sharedStore] colorForNum:colorNum];
    
    NSInteger iconNum = [[SRMEventStore sharedStore] iconForEventIdentifier:event.eventIdentifier];
    _iconLabel.text = [NSString iconfontIconStringForEnum:[[SRMIconStore sharedStore] iconForNum:iconNum]];
    
    if (![event.location isEqual:@""]) {
        self.locationStackView.hidden = NO;
        self.locationLabel.text = event.location;
    } else {
        self.locationStackView.hidden = YES;
    }

}

@end
