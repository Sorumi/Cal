//
//  SRMMonthBoardViewLayout.h
//  Cal
//
//  Created by Sorumi on 16/8/13.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMStamp;

@protocol SRMMonthBoardViewLayoutDelegate <NSObject>

- (SRMStamp *)stampAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SRMMonthBoardViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<SRMMonthBoardViewLayoutDelegate> delegate;

@end
