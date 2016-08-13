//
//  SRMStampStore.h
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SRMStamp;

@interface SRMStampStore : NSObject

@property (nonatomic, readonly) NSArray *allStampsPath;

+ (instancetype)sharedStore;

- (UIImage *)stampForNum:(NSInteger)num;
- (UIImage *)stampForName:(NSString *)name;

- (NSArray *)monthStampsForYear:(NSInteger)year month:(NSInteger)month;
- (void)addStamp:(SRMStamp *)stamp forYear:(NSInteger)year month:(NSInteger)month;
- (void)deleteStamp:(SRMStamp *)stamp forYear:(NSInteger)year month:(NSInteger)month;

- (BOOL)saveChanges;

@end
