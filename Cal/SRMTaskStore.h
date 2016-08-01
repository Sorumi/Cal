//
//  SRMTaskStore.h
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMTaskStore : NSObject

@property (nonatomic, readonly) NSArray *allTasks;

+ (instancetype)sharedStore;

@end
