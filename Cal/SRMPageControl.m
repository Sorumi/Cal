//
//  SRMPageControl.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMPageControl.h"

@implementation SRMPageControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    
}

- (void) updateDots
{
//    for (int i = 0; i < [self.subviews count]; i++) {
//        UIView * dot = [self.subviews objectAtIndex:i];
//        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-2, -2, 10, 10)];
//        //        CGSize size;
//        //        size.height = 1;     //自定义圆点的大小
//        //        size.width = 1;      //自定义圆点的大小,下边注释set方法是设置view的frame
//        //        [dot setFrame:CGRectMake(dot.frame.origin.x, dot.frame.origin.y, size.width, size.width)];
//        imageView.image = (i == self.currentPage) ? _imagePageHighlited : _imagePageNomal;
//        [dot addSubview:imageView];
//        
//    }
}
@end
