//
//  SRMStamp.h
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMStamp : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic) float xProportion;
@property (nonatomic) float yProportion;
@property (nonatomic) float xScale;
@property (nonatomic) float yScale;

- (instancetype)initWithName:(NSString *)name xProp:(float)xProp yProp:(float)yProp xScale:(float)xScale yScale:(float)yScale;

@end
