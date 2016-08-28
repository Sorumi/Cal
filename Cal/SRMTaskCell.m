//
//  SRMTaskCell.m
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTaskCell.h"
#import "SRMTask.h"
#import "SRMCalendarTool.h"

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMTaskCell ()

@property (nonatomic) IBOutlet UIView *blockView;
@property (nonatomic) IBOutlet UIView *categoryColorView;
@property (nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end

@implementation SRMTaskCell

- (void)awakeFromNib {
    // Initialization code
    
    // shadow
    CALayer *layer = self.blockView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    _checkButton.titleLabel.font = [UIFont iconfontOfSize:20];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTask:(SRMTask *)task
{
    
    _titleLable.text = task.title;
    _dateLabel.text = task.dueDate == nil ? @"" : [[SRMCalendarTool tool] dateFormat:task.dueDate];
    
    [_checkButton setTitle:[NSString iconfontIconStringForEnum:task.finishDate == nil ? IFSquareBlank : IFSquareCheck] forState:UIControlStateNormal];
}

@end
