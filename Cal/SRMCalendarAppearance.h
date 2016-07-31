//
//  SRMCalendarAppearance.h
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SRMCalendarAppearance : NSObject

@property (nonatomic, readonly) NSDictionary *appearanceDictionary;

+ (instancetype)appearanceDictionary;
- (UIColor *)colorForKey:(NSString *)key;

@end
