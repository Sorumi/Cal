//
//  SRMSlideAlertView.h
//  Cal
//
//  Created by Sorumi on 16/8/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRMSlideAlertDelegate <NSObject>

- (void)didClickOnButton:(NSInteger)buttonNum;

@end

@interface SRMSlideAlertView : UIView

@property (nonatomic, weak) id<SRMSlideAlertDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title normalButton:(NSArray *)normalString warnButton:(NSArray *)warnString;

@end
