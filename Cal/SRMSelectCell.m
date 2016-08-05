//
//  SRMSelectCell.m
//  Cal
//
//  Created by Sorumi on 16/8/5.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSelectCell.h"

@interface SRMSelectCell ()

@property (nonatomic, weak) IBOutlet UIView *blockView;
@property (nonatomic, weak) IBOutlet UIImageView *checkImage;

@end

@implementation SRMSelectCell

- (void)awakeFromNib {
    // Initialization code

    CALayer *layer = self.blockView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.checkImage.image = [UIImage imageNamed:@"task_icon_finished"];
    } else {
        self.checkImage.image = [UIImage imageNamed:@"task_icon_unfinished"];
    }

    // Configure the view for the selected state
}

@end
