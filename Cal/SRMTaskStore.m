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
    
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] init];
        //
        SRMTask *task = [[SRMTask alloc] initWithTitle:@"Do design"];
        [_tasks addObject:task];
        
        task = [[SRMTask alloc] initWithTitle:@"Programming" dueDate:[NSDate date]];
        [_tasks addObject:task];
        
        task = [[SRMTask alloc] initWithTitle:@"Do design Do design Do design Do design Do design Do design"];
        [_tasks addObject:task];
        
        task = [[SRMTask alloc] initWithTitle:@"Programming Programming Programming Programming Programming Programming" dueDate:[NSDate date]];
        [_tasks addObject:task];
    }
    return self;
}

@end
