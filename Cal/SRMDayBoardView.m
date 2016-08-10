//
//  SRMDayBoardView.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMDayBoardView.h"
#import "SRMCalendarConstance.h"

@implementation SRMDayBoardView
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

- (instancetype)initWithFrame:(CGRect)frame
{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect newFrame = CGRectMake(0, 0, width, SRMDayBoardCellHeight * 24);
    
    self = [super initWithFrame:newFrame];
    self.backgroundColor = UIColorFromRGB(0xFCFCFC);

    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    
    // string
    CGRect textRect = CGRectMake(6, 6, 50, 20);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"Avenir" size:12],
                                         NSForegroundColorAttributeName: UIColorFromRGB(0xDDDDDD),
                                         NSParagraphStyleAttributeName: textStyle};
    
    for (int i=0; i<24; i++) {
        [[NSString stringWithFormat:@"%d:00", i] drawInRect: textRect withAttributes: textFontAttributes];
        textRect.origin.y += SRMDayBoardCellHeight;
    }

    
    // line
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0xDDDDDD).CGColor);
    
    CGContextSetLineWidth(context, 0.5f);
    for (int i=0; i<24; i++) {
        CGFloat y = SRMDayBoardCellHeight * i;
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, width, y);
    }
    
    CGContextStrokePath(context);

    // dashed line
    if ([[[self layer] sublayers] objectAtIndex:0]) {
        self.layer.sublayers = nil;
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.bounds];
    [shapeLayer setPosition:self.center];
    [shapeLayer setFillColor:UIColorFromRGB(0xDDDDDD).CGColor];
    [shapeLayer setStrokeColor:[UIColor colorWithWhite:0.9 alpha:1].CGColor];
    [shapeLayer setLineWidth:0.5f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    [shapeLayer setLineDashPattern:@[@(3), @(4)]];
    
    CGMutablePathRef path = CGPathCreateMutable();

    for (int i=0; i<24; i++) {
        CGFloat y = SRMDayBoardCellHeight * i + SRMDayBoardCellHeight / 2;
        CGPathMoveToPoint(path, NULL, 0, y);
        CGPathAddLineToPoint(path, NULL, width, y);
        
        [shapeLayer setPath:path];
    }

    CGPathRelease(path);
    
    [[self layer] addSublayer:shapeLayer];
}


@end
