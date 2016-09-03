//
//  SRMEventDetailViewController.h
//  Cal
//
//  Created by Sorumi on 16/8/15.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "StaticDataTableViewController.h"

@interface SRMEventDetailViewController : StaticDataTableViewController

@property (nonatomic, strong) EKEvent *event;

@end
