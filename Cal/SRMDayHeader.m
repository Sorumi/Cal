//
//  SRMDayHeader.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMDayHeader.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarAppearance.h"

@interface SRMDayHeader ()

@property (nonatomic) CGFloat width;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *titleWidthArray;
@property (nonatomic, strong) UIView *borderView;

@end

@implementation SRMDayHeader

- (void)awakeFromNib
{
    self.titleArray = @[@"List", @"Schedule"];
    self.buttonArray = [[NSMutableArray alloc] init];
    self.titleWidthArray = [[NSMutableArray alloc] init];

    self.width = [UIScreen mainScreen].bounds.size.width / self.titleArray.count;
    CGFloat width = self.width;

    CGRect frame = CGRectMake(0, 0, width, SRMDayHeaderHeight);
    
    for (NSString *title in self.titleArray) {
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[[SRMCalendarAppearance appearanceDictionary] colorForKey:@"CalendarHeaderColor"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:button];
        frame.origin.x += width;
        
        [self.buttonArray addObject:button];
        [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        CGSize stringsize = [title sizeWithAttributes:@{NSFontAttributeName : button.titleLabel.font}];
        [self.titleWidthArray addObject:[NSNumber numberWithLong:stringsize.width]];
    }
    
    // border view
    self.borderView = [[UIView alloc] initWithFrame:CGRectMake(0, SRMDayHeaderHeight/2-14, width, 28)];
    self.borderView.layer.borderColor = [[SRMCalendarAppearance appearanceDictionary] colorForKey:@"CalendarHeaderColor"].CGColor;
    self.borderView.layer.borderWidth = 1.2;
    self.borderView.layer.cornerRadius = 14;
    [self addSubview:self.borderView];

    // shadow
    CALayer *layer = self.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 0.5;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    // init
    [self setBorderViewPos:0 animated:NO];
}

- (void)click:(id)sender
{
//    UIButton button = (UIButton *)sender;
    NSInteger num = [self.buttonArray indexOfObject:sender];
    
    if ([_delegate respondsToSelector:@selector(dayHeaderBeginChange:)]) {
        [_delegate dayHeaderBeginChange:num];
    }
    [self setBorderViewPos:num animated:YES];
}

- (void)setBorderViewPos:(NSInteger)num animated:(BOOL)animated
{
    CGRect frame = self.borderView.frame;
    frame.size.width = [self.titleWidthArray[num] floatValue] + 20;
    frame.origin.x = (self.width - frame.size.width)/2 + self.width*num;
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.borderView.frame = frame;
                         }];
    } else {
        self.borderView.frame = frame;
    }

}

@end
