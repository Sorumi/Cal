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
#import "SRMColorStore.h"

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

- (IBAction)check:(id)sender {
    
    [_delegate taskCellDidClickCheckButton:self];

    [_checkButton setTitle:[NSString iconfontIconStringForEnum:_task.finishDate == nil ? IFSquareBlank : IFSquareCheck] forState:UIControlStateNormal];
}

- (void)setTask:(SRMTask *)task
{
    _task = task;
    _titleLable.text = task.title;
    _categoryColorView.backgroundColor = [[SRMColorStore sharedStore] colorForNum:task.colorNum];
    


    [_checkButton setTitle:[NSString iconfontIconStringForEnum:task.finishDate == nil ? IFSquareBlank : IFSquareCheck] forState:UIControlStateNormal];
    
     if ([task.startDate timeIntervalSinceNow] > 0){
         [_checkButton setTitleColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateNormal];
         
         _dateLabel.textColor = [UIColor colorWithWhite:0.95 alpha:1];
         _dateLabel.text = task.startDate == nil ? @"" : [[SRMCalendarTool tool] dateDisplayFormat:task.startDate];
         
         
     } else {
         [_checkButton setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateNormal];
         
         _dateLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1];
         _dateLabel.text = task.dueDate == nil ? @"" : [[SRMCalendarTool tool] dateDisplayFormat:task.dueDate];
     }
}

@end
