//
//  SRMTaskStore.m
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTaskStore.h"
#import "SRMTask.h"
#import "SRMCalendarTool.h"

@interface SRMTaskStore ()

@property (nonatomic, strong) NSMutableArray<SRMTask *> *tasks;

@property (nonatomic, strong) NSMutableDictionary *privateMonthTasks;

@end

@implementation SRMTaskStore

#pragma mark - Properties

- (NSArray *)allTasks
{
    return self.tasks;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMTaskStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMTaskStore sharedStore]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    NSString *taskPath = [self archivePath];
    _tasks = [NSKeyedUnarchiver unarchiveObjectWithFile:taskPath];
    
//    SRMTask *task = [[SRMTask alloc] initWithTitle:@"Do design"];
//    task.finishDate = [[SRMCalendarTool tool] dateWithYear:2016 month:8 day:20];
//    [_tasks addObject:task];
    
    
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] init];
        //
//        SRMTask *task = [[SRMTask alloc] initWithTitle:@"Do design"];
//        [_tasks addObject:task];
//        
//        task = [[SRMTask alloc] initWithTitle:@"Programming" dueDate:[NSDate date]];
//        [_tasks addObject:task];
//        
//        task = [[SRMTask alloc] initWithTitle:@"Do design Do design Do design Do design Do design Do design"];
//        [_tasks addObject:task];
//        task.finishDate = [NSDate date];
//        
//        task = [[SRMTask alloc] initWithTitle:@"Programming Programming Programming Programming Programming Programming" dueDate:[NSDate date]];
//        [_tasks addObject:task];
    }
    
    if (!_privateMonthTasks) {
        _privateMonthTasks = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Public

- (NSArray *)monthTasks:(NSDate *)date
{
    /////
    [self fetchMonthTasks:date];
    
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    NSArray *sortedArray = self.privateMonthTasks[[tool monthStoreFormat:date]];
    return sortedArray;
}

- (void)fetchMonthTasks:(NSDate *)date
{
    NSMutableArray *unfinishedTasks = [[NSMutableArray alloc] init];
    NSMutableArray *finishedTasks = [[NSMutableArray alloc] init];
    
    SRMCalendarTool *tool = [[SRMCalendarTool alloc] init];
    NSDate *thisMonth = [tool dateByIgnoringTimeComponentsOfDate:[tool beginningOfMonthOfDate:[NSDate date]]];
    NSDate *startDate = [tool dateByIgnoringTimeComponentsOfDate:[tool beginningOfMonthOfDate:date]];
    NSDate *endDate = [tool dateByAddingMonths:1 toDate:startDate];
    
    if (startDate == thisMonth) {
        [_tasks enumerateObjectsUsingBlock:^(SRMTask *task, NSUInteger index, BOOL *stop){
            if ([task.finishDate timeIntervalSinceDate:startDate] > 0 && [task.finishDate timeIntervalSinceDate:endDate] < 0) {
                [finishedTasks addObject:task];
            } else if (!task.finishDate && (!task.startDate || [task.startDate timeIntervalSinceDate:endDate] < 0)) {
                [unfinishedTasks addObject:task];
            }
        }];
        
    } else if ([startDate timeIntervalSinceDate:thisMonth] < 0) {
        [_tasks enumerateObjectsUsingBlock:^(SRMTask *task, NSUInteger index, BOOL *stop){
            if ([task.finishDate timeIntervalSinceDate:startDate] > 0 && [task.finishDate timeIntervalSinceDate:endDate] < 0) {
                [finishedTasks addObject:task];
            }
        }];
        
    } else if ([startDate timeIntervalSinceDate:thisMonth] > 0) {
        [_tasks enumerateObjectsUsingBlock:^(SRMTask *task, NSUInteger index, BOOL *stop){
            if (!task.finishDate && [task.startDate timeIntervalSinceDate:startDate] > 0 &&[task.startDate timeIntervalSinceDate:endDate] < 0) {
                [unfinishedTasks addObject:task];
            }
        }];
    }
    
    [unfinishedTasks addObjectsFromArray:finishedTasks];
    if (unfinishedTasks) {
        self.privateMonthTasks[[tool monthStoreFormat:date]] = unfinishedTasks;
    } else {
        [self.privateMonthTasks removeObjectForKey:[tool monthStoreFormat:date]];
    }
    
}

- (BOOL)editTask:(SRMTask *)task title:(NSString *)title note:(NSString *)note startDate:(NSDate *)startDate dueDate:(NSDate *)dueDate colorNum:(NSInteger)colorNum
{
    if (task) {
        [_tasks removeObject:task];
        
    } else {
        task = [[SRMTask alloc] initWithTitle:title];
    }
    
    task.notes = note;
    task.startDate = startDate;
    task.dueDate = dueDate;
    task.colorNum = colorNum;
    
    [self addTask:task];
    
    if ([self saveChanges]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SRMTaskStoreChangedNotification"
                                                            object:nil];
        return YES;
    } else {
        return NO;
    };
}

#pragma mark - Public

- (void)setCheck:(SRMTask *)task
{
    if (task.finishDate) {
        task.finishDate = nil;
        [self saveChanges];
        
    } else {
        if ([task.startDate timeIntervalSinceNow] < 0 || !task.startDate){
            task.finishDate = [NSDate date];
            [self saveChanges];
        }
    }
}

#pragma mark - Private

- (void)addTask:(SRMTask *)addTask
{
    __block NSUInteger addIndex = _tasks.count;
    [_tasks enumerateObjectsUsingBlock:^(SRMTask *task, NSUInteger index, BOOL *stop){
        if ([task.startDate timeIntervalSinceDate:addTask.startDate] > 0) {
            addIndex = index;
            *stop = YES;
        }
    }];
    if (addIndex == _tasks.count) {
        [_tasks addObject:addTask];
    } else {
        [_tasks insertObject:addTask atIndex:addIndex];
    }
}

#pragma mark - File

- (NSString *)archivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"task.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self archivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.tasks toFile:path];
}

@end
