//
//  SRMIconStore.h
//  Cal
//
//  Created by Sorumi on 16/8/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMIconStore : NSObject

@property (nonatomic, readonly) NSArray *allIcons;

+ (instancetype)sharedStore;

@end
