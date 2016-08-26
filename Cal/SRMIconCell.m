//
//  SRMIconCell.m
//  Cal
//
//  Created by Sorumi on 16/8/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMIconCell.h"
#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMIconCell ()

@property (weak, nonatomic) IBOutlet UILabel *iconLabel;

@end

@implementation SRMIconCell

- (void)awakeFromNib
{
    // Initialization code
    
//    self.layer.borderColor = [UIColor lightGrayColor ].CGColor;
//    self.layer.borderWidth = 0.5;
}

- (void)setIcon:(NSInteger)num
{
    [_iconLabel setFont:[UIFont iconfontOfSize:20]];
     _iconLabel.text = [NSString iconfontIconStringForEnum:num];
}

@end
