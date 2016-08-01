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
@property (nonatomic) NSInteger tagNum;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSDate *finishDate;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title dueDate:(NSDate *)dueDate;

@end
