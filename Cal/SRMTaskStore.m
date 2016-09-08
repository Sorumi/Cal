//
//  SRMTaskStore.m
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTaskStore.h"
#import "SRMTask.h"

@interface SRMTaskStore ()

@property (nonatomic, strong) NSMutableArray<SRMTask *> *tasks;

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
    return self;
}

#pragma mark - Public

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
    
    [_tasks addObject:task];
    return [self saveChanges];
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
