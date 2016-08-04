//
//  SRMTimeDecoration.m
//  Cal
//
//  Created by Sorumi on 16/8/4.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTimeDecoration.h"

@implementation SRMTimeDecoration



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.8 alpha:0.5].CGColor);
    
    CGContextSetLineWidth(context, 0.5f);
    
    CGContextMoveToPoint(context, 0.0f, 0.0f);
    CGContextAddLineToPoint(context, width, height/2);
    CGContextAddLineToPoint(context, 0.0f, height);
    
    CGContextStrokePath(context);
    

}


@end
