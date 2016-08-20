//
//  SRMCalendarToolbar.m
//  Cal
//
//  Created by Sorumi on 16/8/3.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarToolbar.h"
#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMCalendarToolbar ()

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *mainButtons;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *appearanceButtons;

@end

@implementation SRMCalendarToolbar

- (void)awakeFromNib
{
    [super awakeFromNib];

    CALayer *layer =  self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.5;
    
    IFIcon mainIFIcon[] = {IFPaintRoll, IFAdd};
    IFIcon appearanceIFIcon[] = {IFArrowLeft, IFSquareSelect, IFCalendar};
    
    for (UIButton *button in _mainButtons) {
        button.titleLabel.font = [UIFont iconfontOfSize:20];
        IFIcon icon = mainIFIcon[[_mainButtons indexOfObject:button]];
        [button setTitle:[NSString iconfontIconStringForEnum:icon] forState:UIControlStateNormal];
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    }

    for (UIButton *button in _appearanceButtons) {
        button.titleLabel.font = [UIFont iconfontOfSize:20];
        IFIcon icon = appearanceIFIcon[[_appearanceButtons indexOfObject:button]];
        [button setTitle:[NSString iconfontIconStringForEnum:icon] forState:UIControlStateNormal];
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    }

}

- (void)tintColorDidChange
{
    for (UIButton *button in _mainButtons) {
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    for (UIButton *button in _appearanceButtons) {
        [button setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
}

#pragma mark - Theme Properties

- (void)setToollbarTextColor:(UIColor *)toollbarTextColor
{
    _toollbarTextColor = toollbarTextColor;
    self.tintColor = _toollbarTextColor;
//    [self setNeedsDisplay];
}
@end
