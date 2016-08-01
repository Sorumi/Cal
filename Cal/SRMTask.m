//
//  SRMTask.m
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTask.h"

@implementation SRMTask

- (instancetype)initWithTitle:(NSString *)title
{
    return [self initWithTitle:title dueDate:nil];
}

- (instancetype)initWithTitle:(NSString *)title dueDate:(NSDate *)dueDate
{
    self = [super init];
    if (self) {
        self.title = title;
        self.tagNum = 0;
        self.dueDate = dueDate;
        
        NSUUID *uuid = [[NSUUID alloc] init];
        self.taskIdentifier = [uuid UUIDString];
    }
    return self;
}



@end
