//
//  SRMSelectCalendarCell.m
//  Cal
//
//  Created by Sorumi on 16/8/27.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSelectCalendarCell.h"
#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMSelectCalendarCell ()

@property (weak, nonatomic) IBOutlet UIView *blockView;

@property (weak, nonatomic) IBOutlet UILabel *checkLabel;

@end

@implementation SRMSelectCalendarCell

- (void)awakeFromNib {
    // Initialization code
    
    CALayer *layer = self.blockView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    [_checkLabel setFont:[UIFont iconfontOfSize:20]];
    _checkLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
    
    _colorButton.titleLabel.font = [UIFont iconfontOfSize:6];
    [_colorButton setTitle:[NSString iconfontIconStringForEnum:IFTriangleSmall] forState:UIControlStateNormal];
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

- (IBAction)selectColor:(id)sender {
    self.buttonAction();
}


@end
