//
//  SRMColorStore.m
//  Cal
//
//  Created by Sorumi on 16/8/28.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "ColorUtils.h"
#import "SRMColorStore.h"

@interface SRMColorStore ()

@property (nonatomic, strong) NSArray *colors;

@end

@implementation SRMColorStore

#pragma mark - Properties

- (NSArray *)allColors
{
    return self.colors;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMColorStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMColorStore sharedStore]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (!_colors) {
        
//        _colors = @[@"EEC0BE", @"F3D3C9", @"F6F5E0", @"EAF1D3", @"D9F1ED", @"E8F7F9", @"E2EBF5", @"E9E2F3", @"F6ECF8", @"E9E9E9",
//                    @"EA866B", @"EEAF7A", @"FFE486", @"CFE487", @"94E5D5", @"75D8E5", @"95C6F3", @"CFB6F4", @"F6CBFF", @"BEBEBE"];
        
        _colors = @[@"E3645A", @"F48984", @"FDB8A1", @"F7CC9B", @"F8D76E", @"FEE9A5", @"F0E0BC", @"D1CCC6",
                    @"B6D7B3", @"BEE1DA", @"A7DAD8", @"92BCC3", @"93A9BD", @"B9CDDC", @"BABBDE", @"928BA9",
                    @"CA9ECE", @"EFCEED", @"FECEDC", @"FAA5B3"];
    }
    return self;
}

#pragma mark - Public

- (UIColor *)colorForNum:(NSInteger)num
{
    return [UIColor colorWithString:self.colors[num]];
}

@end
