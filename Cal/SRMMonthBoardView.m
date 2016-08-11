//
//  SRMMonthBoardView.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthBoardView.h"
#import "SRMStamp.h"
#import "SRMStampStore.h"
#import "SRMStampView.h"

@interface SRMMonthBoardView ()

@end

@implementation SRMMonthBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
//        self.layer.borderWidth = 3;
//        self.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return self;
}

- (void)setEditMode
{
    self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.2];
}

- (void)setStampsForYear:(NSInteger)year month:(NSInteger)month
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    NSArray *stamps = [[SRMStampStore sharedStore] monthStampsForYear:year month:month];
    
    for (SRMStamp *stamp in stamps) {
        SRMStampView *view = [[SRMStampView alloc] initWithImage:[[SRMStampStore sharedStore] stampForName:stamp.name] x:stamp.xProportion*width y:stamp.yProportion*height];
        [self addSubview:view];
    }
}

@end
