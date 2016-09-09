//
//  SRMAddViewController.h
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@class EKEvent;

@interface SRMEventEditViewController : StaticDataTableViewController

@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, copy) void (^didEdit)();

@end
