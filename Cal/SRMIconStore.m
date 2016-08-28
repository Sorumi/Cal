//
//  SRMIconStore.m
//  Cal
//
//  Created by Sorumi on 16/8/26.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMIconStore.h"
#import "NSString+IconFont.h"

@interface SRMIconStore ()

@property (nonatomic, strong) NSArray *iconNames;

@end

@implementation SRMIconStore

#pragma mark - Properties

- (NSArray *)allIcons
{
    return self.iconNames;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMIconStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMIconStore sharedStore]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (!_iconNames) {
        _iconNames = @[@(IFDefault),
                       @(IFArrowRight),
                       @(IFBell),
                       @(IFCalendar),
                       @(IFClock),
                       @(IFCross),
                       @(IFLocation),
                       @(IFNote),
                       @(IFPaintRoll),
                       @(IFRepeat),
                       @(IFSquareBlank),
                       @(IFSquareCheck),
                       @(IFTick),
                       @(IFTrashCan),
                       @(IFAdd),
                       @(IFSquareSelect),
                       @(IFArrowLeft),
                       @(IFArrowRight),
                       @(IFBell),
                       @(IFCalendar),
                       @(IFClock),
                       @(IFCross),
                       @(IFLocation),
                       @(IFNote),
                       @(IFPaintRoll),
                       @(IFRepeat),
                       @(IFSquareBlank),
                       @(IFSquareCheck),
                       @(IFTick),
                       @(IFTrashCan),
                       @(IFAdd),
                       @(IFSquareSelect),
                       @(IFArrowLeft),
                       @(IFArrowRight),
                       @(IFBell),
                       @(IFCalendar),
                       @(IFClock),
                       @(IFCross),
                       @(IFLocation),
                       @(IFNote),
                       @(IFPaintRoll),
                       @(IFRepeat),
                       @(IFSquareBlank),
                       @(IFSquareCheck),
                       @(IFTick),
                       @(IFTrashCan),
                       @(IFAdd),
                       @(IFSquareSelect)
                       ];
    }
    return self;
}

#pragma mark - Public

- (NSInteger)iconForNum:(NSInteger)num
{
    return [self.iconNames[num] integerValue];
}

@end
