//
//  SRMSwitch.h
//  Cal
//
//  Created by Sorumi on 16/8/4.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMSwitch;

@protocol SRMSwitchDelegate <NSObject>

@optional
- (BOOL)switchView:(SRMSwitch *)switchView shouleToggleWithValue:(BOOL)value;
- (void)switchView:(SRMSwitch *)switchView didEndToggleWithValue:(BOOL)value;

@end


@interface SRMSwitch : UIView

@property (nonatomic) BOOL value;
@property(nonatomic, weak) IBOutlet id<SRMSwitchDelegate> delegate;

@end
