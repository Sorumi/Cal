//
//  SRMTaskEditViewController.h
//  Cal
//
//  Created by Sorumi on 16/9/6.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@class SRMTask;

@interface SRMTaskEditViewController : StaticDataTableViewController

@property (nonatomic, strong) SRMTask *task;
@property (nonatomic, copy) void (^didEdit)();

@end
