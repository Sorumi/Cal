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
    return [self initWithTitle:title startDate:nil dueDate:nil];
}

- (instancetype)initWithTitle:(NSString *)title startDate:(NSDate *)startDate dueDate:(NSDate *)dueDate
{
    self = [super init];
    if (self) {
        _title = title;
        _colorNum = 0;
        _startDate = startDate;
        _dueDate = dueDate;
        
        NSUUID *uuid = [[NSUUID alloc] init];
        self.taskIdentifier = [uuid UUIDString];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.taskIdentifier forKey:@"taskIdentifier"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeInteger:self.colorNum forKey:@"colorNum"];
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeObject:self.dueDate forKey:@"dueDate"];
    [aCoder encodeObject:self.finishDate forKey:@"finishDate"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _taskIdentifier = [aDecoder decodeObjectForKey:@"taskIdentifier"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _colorNum = [aDecoder decodeIntegerForKey:@"colorNum"];
        _startDate = [aDecoder decodeObjectForKey:@"startDate"];
        _dueDate = [aDecoder decodeObjectForKey:@"dueDate"];
        _finishDate = [aDecoder decodeObjectForKey:@"finishDate"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
    }
    return self;
}

@end
