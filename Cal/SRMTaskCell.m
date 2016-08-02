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

@interface SRMTaskCell ()

@property (nonatomic) IBOutlet UIView *blockView;
@property (nonatomic) IBOutlet UIView *categoryColorView;
@property (nonatomic) IBOutlet UIButton *iconImage;
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
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTask:(SRMTask *)task
{
    SRMCalendarTool *tool = [[SRMCalendarTool alloc] init];
    self.titleLable.text = task.title;
    self.dateLabel.text = task.dueDate == nil ? @"" : [tool dateFormat:task.dueDate];

    self.iconImage.imageView.image = task.finishDate == nil ? [UIImage imageNamed:@"task_icon_unfinished"] : [UIImage imageNamed:@"task_icon_finished"];
}

@end
