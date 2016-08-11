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

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;

@end

@implementation SRMMonthBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)setEditMode:(BOOL)isEditMode
{
    if (isEditMode) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.2];
        
    } else {
        self.userInteractionEnabled = NO;
        self.backgroundColor = nil;
    }
}

- (void)setYear:(NSInteger)year month:(NSInteger)month
{
    _year = year;
    _month = month;
}

- (void)setStamps
{
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    NSArray *stamps = [[SRMStampStore sharedStore] monthStampsForYear:_year month:_month];
    
    for (SRMStamp *stamp in stamps) {
        SRMStampView *view = [[SRMStampView alloc] initWithStamp:stamp image:[[SRMStampStore sharedStore] stampForName:stamp.name] x:stamp.xProportion*width y:stamp.yProportion*height];
        [self addSubview:view];
    }
}

- (void)deleteStamp:(SRMStamp *)stamp
{
    [[SRMStampStore sharedStore] deleteStamp:stamp forYear:_year month:_month];
}

@end
