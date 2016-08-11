//
//  SRMStampView.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMStampView.h"

@interface SRMStampView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SRMStampView

- (instancetype)initWithImage:(UIImage *)image x:(CGFloat)x y:(CGFloat)y
{
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:image];
        self.center = CGPointMake(x, y);
        [self addSubview:_imageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
