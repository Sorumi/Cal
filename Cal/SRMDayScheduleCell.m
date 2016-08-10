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

@interface SRMDayScheduleCell ()

@property (nonatomic) IBOutlet UIView *categoryColorView;
@property (nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIStackView *locationStackView;
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
}

- (void)setEvent:(EKEvent *)event
{
    self.titleLable.text = event.title;
    self.categoryColorView.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
        
    if (![event.location isEqual:@""]) {
        self.locationStackView.hidden = NO;
        self.locationLabel.text = event.location;
    } else {
        self.locationStackView.hidden = YES;
    }

}

@end
