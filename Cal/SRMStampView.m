//
//  SRMStampView.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMStampView.h"
#import "SRMStamp.h"
#import "SRMMonthBoardView.h"

@interface SRMStampView ()

@property (nonatomic, strong) SRMStamp *stamp;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SRMStampView

- (instancetype)initWithStamp:(SRMStamp *)stamp image:(UIImage *)image x:(CGFloat)x y:(CGFloat)y
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        self.center = CGPointMake(x, y);
        [self addSubview:_imageView];
        _stamp = stamp;
        
        // gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)handleTap:(UIPanGestureRecognizer *)gesture
{
    [self setEditMode:YES];
}

- (void)setEditMode:(BOOL)isEditMode
{
    CGRect frame = CGRectMake(self.frame.size.width-12, 0, 12, 12);
    UIButton *delete = [[UIButton alloc] initWithFrame:frame];
    delete.backgroundColor = [UIColor darkGrayColor];
    delete.layer.cornerRadius = 6;
    [delete addTarget:self action:@selector(deleteStamp:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delete];
}

- (void)deleteStamp:(id)sender
{
    SRMMonthBoardView *board = (SRMMonthBoardView *)[self superview];
    [board deleteStamp:_stamp];
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
