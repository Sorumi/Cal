//
//  SRMMonthHeaderView.m
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthHeaderView.h"

@interface SRMMonthHeaderView ()

@property (nonatomic, strong) NSArray *weekday;

@end

@implementation SRMMonthHeaderView


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.weekday = @[@"Sun",@"Mon",@"Tues",@"Wed",@"Thur",@"Fri",@"Sat"];
    
    int width = [UIScreen mainScreen].bounds.size.width/7;
//    NSLog(@"%f", self.bounds.size.height);
//    double y = self.bounds.size.height - 30;
    CGRect labelRect = CGRectMake(2, 40, width, 30);
    
    
    for (int i=0; i<7; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
        label.text = self.weekday[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
        labelRect.origin.x += width;
    }

}
@end
