//
//  SRMRepeatEndViewController.h
//  Cal
//
//  Created by Sorumi on 16/8/6.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@protocol SRMRepeatEndDelegate <NSObject>

@optional
- (void)repeadEndViewDidBackWithDate:(NSDate *)endDate;

@end

@interface SRMRepeatEndViewController : StaticDataTableViewController

@property (nonatomic, weak) id <SRMRepeatEndDelegate> delegate;

@property (nonatomic, strong) NSDate *date;

@end
