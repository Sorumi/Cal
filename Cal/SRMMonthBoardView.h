//
//  SRMMonthBoardView.h
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMStamp;

@interface SRMMonthBoardView : UICollectionReusableView

- (void)setEditMode:(BOOL)isEditMode;
- (void)setYear:(NSInteger)year month:(NSInteger)month;
- (void)setStamps;
- (void)deleteStamp:(SRMStamp *)stamp;

@end
