//
//  SRMTaskDetailTableViewController.h
//  Cal
//
//  Created by Sorumi on 16/9/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@class SRMTask;

@interface SRMTaskDetailViewController : StaticDataTableViewController

@property (nonatomic, strong) SRMTask *task;

@end
