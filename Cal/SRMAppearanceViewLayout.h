//
//  SRMAppearanceViewLayout.h
//  Cal
//
//  Created by Sorumi on 16/8/16.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMAppearanceViewLayout;

@protocol SRMAppearanceViewLayoutDelegate <NSObject>

- (void)didPrepareLayout:(SRMAppearanceViewLayout *)layout;

@end

@interface SRMAppearanceViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id<SRMAppearanceViewLayoutDelegate> delegate;
@property (nonatomic) NSInteger page;

@end
