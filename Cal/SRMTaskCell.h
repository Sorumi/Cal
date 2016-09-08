//
//  SRMTaskCell.h
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMTask;
@class SRMTaskCell;

@protocol SRMTaskCellDelegate <NSObject>

- (void)taskCellDidClickCheckButton:(SRMTaskCell *)cell;

@end

@interface SRMTaskCell : UITableViewCell

@property (nonatomic, strong) SRMTask *task;
@property (nonatomic, weak) id<SRMTaskCellDelegate> delegate;

- (void)setTask:(SRMTask *)task;

@end
