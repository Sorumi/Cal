//
//  SRMCalendarToolbar.h
//  Cal
//
//  Created by Sorumi on 16/8/3.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMCalendarToolbar : UIView

@property (weak, nonatomic) IBOutlet UIStackView *mainToolbar;
@property (weak, nonatomic) IBOutlet UIStackView *appearanceToolbar;

@property (nonatomic, strong) UIColor *toollbarTextColor;

@end
