//
//  SRMColorStore.h
//  Cal
//
//  Created by Sorumi on 16/8/28.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMColorStore : NSObject

@property (nonatomic, readonly) NSArray *allColors;

+ (instancetype)sharedStore;

- (UIColor *)colorForNum:(NSInteger)num;

@end
