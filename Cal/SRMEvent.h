//
//  SRMEvent.h
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface SRMEvent : NSObject

@property (nonatomic, strong) EKEvent *systemEvent;
@property (nonatomic, strong) NSString *systemEventIdentifer;
@property (nonatomic) NSInteger iconNum;

- (instancetype)initWithSystemEvent:(EKEvent *)systemEvent;
@end
