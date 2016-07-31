//
//  SRMEventCell.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventCell.h"
#import "SRMCalendarConstance.h"

@interface SRMEventCell ()

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@end

@implementation SRMEventCell

- (void)awakeFromNib {
    // Initialization code
    
    self.isFirstTimeViewDidLayoutSubviews = YES;
}

- (void)layoutSubviews
{
    if (self.isFirstTimeViewDidLayoutSubviews) {
        
        CGRect frame = self.contentView.frame;
        CGRect newFrame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(SRMEventCellSpacing/2, 20, SRMEventCellSpacing/2, 20));
        
        UIView *bgRect = [[UIView alloc] initWithFrame:newFrame];
        bgRect.layer.cornerRadius = 2;
        
        bgRect.backgroundColor = [UIColor whiteColor];
        
        CALayer *layer = bgRect.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 1;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
        
        [self.contentView addSubview:bgRect];
        [self.contentView sendSubviewToBack:bgRect];
        
        self.isFirstTimeViewDidLayoutSubviews = NO;
    }
   

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
