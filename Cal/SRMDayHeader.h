//
//  SRMDayHeader.h
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRMDayHeaderDelegate <NSObject>

@optional
- (void)dayHeaderBeginChange:(NSInteger)num;

@end

@interface SRMDayHeader : UIView

@property (nonatomic, weak) id<SRMDayHeaderDelegate> delegate;

- (void)setBorderViewPos:(NSInteger)num animated:(BOOL)animated;

@end
