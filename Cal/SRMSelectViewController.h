//
//  SRMEventRepeatViewController.h
//  Cal
//
//  Created by Sorumi on 16/8/5.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMCalendarConstance.h"

@protocol SRMSelectViewDelegate <NSObject>

@optional
- (void)selectView:(SRMEventSelectMode)selectMode didBackWithSelectRow:(NSInteger)selectRow;

@end

@interface SRMSelectViewController : UITableViewController

@property (nonatomic, weak) id <SRMSelectViewDelegate> delegate;

@property (nonatomic) SRMEventSelectMode selectMode;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic) NSInteger selectedRow;

@end
