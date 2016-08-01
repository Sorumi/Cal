//
//  SRMListHeader.m
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMListHeader.h"

@interface SRMListHeader ()

@end

@implementation SRMListHeader

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.7 alpha:0.5].CGColor);
    
    CGContextSetLineWidth(context, 1.0f);
    
    CGContextMoveToPoint(context, 16.0f, 40.0f);
    CGContextAddLineToPoint(context, 66.0f, 40.0f);
    
    CGContextStrokePath(context);

}


@end
