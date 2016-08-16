//
//  SRMStamp.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMStamp.h"

@implementation SRMStamp

- (instancetype)initWithName:(NSString *)name xProp:(float)xProp yProp:(float)yProp xScale:(float)xScale yScale:(float)yScale
{
    self = [super init];
    if (self) {
        _name = name;
        _xProportion = xProp;
        _yProportion = yProp;
        _xScale = xScale;
        _yScale = yScale;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeFloat:self.xProportion forKey:@"xProportion"];
    [aCoder encodeFloat:self.yProportion forKey:@"yProportion"];
    [aCoder encodeFloat:self.xScale forKey:@"xScale"];
    [aCoder encodeFloat:self.yScale forKey:@"yScale"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _xProportion = [aDecoder decodeFloatForKey:@"xProportion"];
        _yProportion = [aDecoder decodeFloatForKey:@"yProportion"];
        _xScale = [aDecoder decodeFloatForKey:@"xScale"];
        _yScale = [aDecoder decodeFloatForKey:@"yScale"];
    }
    return self;
}

@end
