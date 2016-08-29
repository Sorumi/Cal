//
//  SRMSlideAlertView.m
//  Cal
//
//  Created by Sorumi on 16/8/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSlideAlertView.h"

#import "ColorUtils.h"

@interface SRMSlideAlertView ()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SRMSlideAlertView

#pragma mark - Initialization

- (instancetype)initWithTitle:(NSString *)title normalButton:(NSArray *)normalString warnButton:(NSArray *)warnString
{
    NSInteger num = normalString.count + warnString.count;
    CGFloat viewWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat viewHeight = (title ? 50 : 15) + num * 55;
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    CGRect newFrame = CGRectMake(0, height, viewWidth, viewHeight);
    self = [super initWithFrame:newFrame];
    
    self.backgroundColor = [UIColor whiteColor];
    if (title) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 50)];
        titleLabel.text = title;
        titleLabel.font = [UIFont fontWithName:@"Avenir" size:15];
        titleLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    
    _buttons = [[NSMutableArray alloc] init];
    CGFloat y = (title ? 50 : 15);
    for (NSString *normal in normalString) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, y, viewWidth-60, 40)];
        button.backgroundColor = [UIColor colorWithString:@"D1E6E2"];
        [button setTitle:normal forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [_buttons addObject:button];
        [self addSubview:button];
        y += 55;
    }
    
    for (NSString *warn in warnString) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, y, viewWidth-60, 40)];
        button.backgroundColor = [UIColor colorWithString:@"F7DCD3"];
        [button setTitle:warn forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [_buttons addObject:button];
        [self addSubview:button];
        y += 55;
    }
    
//    NSLog(@"%@", _buttons);
    return self;
}


#pragma mark - Action

- (void)clickButton:(UIButton *)sender
{
    NSInteger num = [_buttons indexOfObject:sender];
    [_delegate didClickOnButton:num];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
