//
//  SRMCalendarViewController.h
//  Cal
//
//  Created by Sorumi on 16/7/27.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EKEvent;

@interface SRMCalendarViewController : UIViewController

@property (nonatomic, strong) NSDate *date;
- (EKEvent *)eventForRow:(NSInteger)row;

@end
