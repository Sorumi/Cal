//
//  SRMEventRepeatViewController.h
//  Cal
//
//  Created by Sorumi on 16/8/5.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRMSelectViewDelegate <NSObject>

@optional
- (void)selectView:(NSString *)titleName didBackWithSelectRow:(NSInteger)selectRow;

@end

@interface SRMSelectViewController : UITableViewController

@property (nonatomic, assign) id <SRMSelectViewDelegate> delegate;

@property (nonatomic, strong) NSString *segueIdentifier;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic) NSInteger selectedRow;

@end
