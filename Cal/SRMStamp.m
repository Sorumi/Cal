//
//  SRMStamp.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMStamp.h"

@implementation SRMStamp

- (instancetype)initWithName:(NSString *)name xProp:(float)xProp yProp:(float)yProp
{
    self = [super init];
    if (self) {
        _name = name;
        _xProportion = xProp;
        _yProportion = yProp;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeFloat:self.xProportion forKey:@"xProportion"];
    [aCoder encodeFloat:self.yProportion forKey:@"yProportion"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _xProportion = [aDecoder decodeFloatForKey:@"xProportion"];
        _yProportion = [aDecoder decodeFloatForKey:@"yProportion"];
    }
    return self;
}

@end
