//
//  SRMBoardStampCell.h
//  Cal
//
//  Created by Sorumi on 16/8/13.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMStamp;

@interface SRMBoardStampCell : UICollectionViewCell

@property (nonatomic, strong) SRMStamp *stamp;

- (void)setStamp:(SRMStamp *)stamp;
- (void)setEditMode:(BOOL)isEditMode;

@end
