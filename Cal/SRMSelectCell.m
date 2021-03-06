//
//  SRMSelectCell.m
//  Cal
//
//  Created by Sorumi on 16/8/5.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSelectCell.h"
#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMSelectCell ()

@property (nonatomic, weak) IBOutlet UIView *blockView;
@property (nonatomic, weak) IBOutlet UILabel *checkLabel;

@end

@implementation SRMSelectCell

- (void)awakeFromNib {
    // Initialization code

    CALayer *layer = self.blockView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    [_checkLabel setFont:[UIFont iconfontOfSize:20]];
    _checkLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        _checkLabel.text = [NSString iconfontIconStringForEnum:IFSquareCheck];
    } else {
        _checkLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
    }
}

@end
