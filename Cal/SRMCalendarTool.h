//
//  SRMCalendarTool.h
//  Cal
//
//  Created by Sorumi on 16/7/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMCalendarTool : NSObject

@property (nonatomic, strong) NSDateComponents *components;

- (NSUInteger)dayCount;
- (NSUInteger)firstWeekDay;

@end
