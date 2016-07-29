//
//  SRMCalendarViewController.h
//  Cal
//
//  Created by Sorumi on 16/7/27.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMCalendarViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;

- (void)MonthToWeek:(UISwipeGestureRecognizer *)gesture;

@end
