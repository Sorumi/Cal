//
//  SRMTaskStore.h
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SRMTask;

@interface SRMTaskStore : NSObject

@property (nonatomic, readonly) NSArray *allTasks;

+ (instancetype)sharedStore;

- (void)fetchMonthTasks:(NSDate *)date;
- (void)fetchThreeMonthsTasks:(NSDate *)date;
- (NSArray *)monthTasks:(NSDate *)date;

- (BOOL)editTask:(SRMTask *)task title:(NSString *)title note:(NSString *)note startDate:(NSDate *)startDate dueDate:(NSDate *)dueDate colorNum:(NSInteger)colorNum;
- (BOOL)deleteTask:(SRMTask *)task;
- (void)setCheck:(SRMTask *)task;

@end
