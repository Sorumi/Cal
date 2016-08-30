//
//  SRMSwitch.m
//  Cal
//
//  Created by Sorumi on 16/8/4.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSwitch.h"

@interface SRMSwitch ()

@property (nonatomic, strong) UIView *bgview;
@property (nonatomic, strong) UIView *circle;

@end

@implementation SRMSwitch

- (void)setUp
{
    self.backgroundColor = nil;
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

- (void)awakeFromNib
{
    [self setUp];
    
    UITapGestureRecognizer *toggle =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(toggle:)];
    [self addGestureRecognizer:toggle];
    self.value = NO;

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat height = self.bounds.size.height;

    self.bgview = [[UIView alloc] initWithFrame:self.bounds];
    self.bgview.layer.cornerRadius = height/2;
    [self addSubview:self.bgview];
    
    if (_value) {
        self.circle = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - height/8 - height*3/4, height/8, height*3/4, height*3/4)];
        self.bgview.backgroundColor = self.tintColor;
    } else {
        self.circle = [[UIView alloc] initWithFrame:CGRectMake(height/8, height/8, height*3/4, height*3/4)];
        self.bgview.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    }
    self.circle.layer.cornerRadius = height*3/8;
    self.circle.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.circle];
    
}

- (void)tintColorDidChange
{
    if (_value) {
        self.bgview.backgroundColor = self.tintColor;
    }
}

- (void)toggle:(UITapGestureRecognizer *)recognizer
{
    BOOL shouldToggle = YES;
    if ([_delegate respondsToSelector:@selector(switchView:shouleToggleWithValue:)]) {
        shouldToggle = [_delegate switchView:self shouleToggleWithValue:self.value];
    }
    
    if (shouldToggle) {
        if (_value) {
            [self setOff];
        } else {
            [self setOn];
        }
        _value = !_value;
        if ([_delegate respondsToSelector:@selector(switchView:didEndToggleWithValue:)]) {
            [_delegate switchView:self didEndToggleWithValue:self.value];
        }
    }
}

- (void)setOn
{
    CGFloat height = self.frame.size.height;
    CGRect newFrame = self.circle.frame;
    newFrame.origin.x = self.frame.size.width - height/8 - height*3/4;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bgview.backgroundColor = self.tintColor;
                         self.circle.frame = newFrame;
                     }];
}

- (void)setOff
{
    CGFloat height = self.frame.size.height;
    CGRect newFrame = self.circle.frame;
    newFrame.origin.x = height/8;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bgview.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
                         self.circle.frame = newFrame;
                     }];
}

@end
