//
//  SRMEvent.m
//  Cal
//
//  Created by Sorumi on 16/7/31.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEvent.h"

@implementation SRMEvent

- (instancetype)initWithSystemEvent:(EKEvent *)systemEvent
{
    self = [super init];
    if (self) {
        self.systemEvent = systemEvent;
        self.systemEventIdentifer = systemEvent.eventIdentifier;
        self.iconNum = 0;
    }
    return self;
}



@end
