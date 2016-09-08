//
//  SRMTask.h
//  Cal
//
//  Created by Sorumi on 16/8/1.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMTask : NSObject

@property (nonatomic, strong) NSString *taskIdentifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSInteger colorNum;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, strong) NSString *notes;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title startDate:(NSDate *)startDate dueDate:(NSDate *)dueDate;

//- (void)setCheck;

@end
