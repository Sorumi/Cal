//
//  SRMMonthBoardView.h
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMMonthBoardView : UICollectionReusableView

- (void)setEditMode;

- (void)setStampsForYear:(NSInteger)year month:(NSInteger)month;

@end
