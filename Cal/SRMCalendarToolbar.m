//
//  SRMCalendarToolbar.m
//  Cal
//
//  Created by Sorumi on 16/8/3.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarToolbar.h"

@implementation SRMCalendarToolbar

- (void)awakeFromNib
{
    [super awakeFromNib];

    CALayer *layer =  self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.5;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
