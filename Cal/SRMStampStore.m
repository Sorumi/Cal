//
//  SRMStampStore.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMStampStore.h"
#import "SRMStamp.h"

@interface SRMStampStore ()

@property (nonatomic, strong) NSMutableArray<NSString *> *stampsPath;

@property (nonatomic, strong) NSMutableDictionary *monthStamps;

@end

@implementation SRMStampStore

#pragma mark - Properties

- (NSArray *)allStampsPath
{
    return self.stampsPath;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMStampStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMStampStore sharedStore]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (!_stampsPath) {
        _stampsPath = [[NSMutableArray alloc] init];
        [self getPNGPath];
        
        NSString *path = [self itemArchivePath];
        _monthStamps = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

        if (!_monthStamps) {
            _monthStamps = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

#pragma mark - Private

- (void)getPNGPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Stamp" ofType:@"bundle"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    
    while((path = [enumerator nextObject]) != nil) {
        [_stampsPath addObject:path];
    }
}

#pragma mark - Public

- (UIImage *)stampForNum:(NSInteger)num
{
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Stamp.bundle/%@", self.stampsPath[num]]];

    return [UIImage imageWithContentsOfFile:imagePath];
}

- (UIImage *)stampForName:(NSString *)name
{
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Stamp.bundle/%@", name]];

    return [UIImage imageWithContentsOfFile:imagePath];
}

- (NSArray *)monthStampsForYear:(NSInteger)year month:(NSInteger)month
{
    return self.monthStamps[[NSString stringWithFormat:@"%lu-%lu", year, month]];
}

- (void)addStamp:(SRMStamp *)stamp forYear:(NSInteger)year month:(NSInteger)month
{
    NSMutableArray *stamps;
    if ([self monthStampsForYear:year month:month]) {
        stamps = [[self monthStampsForYear:year month:month] mutableCopy];

    } else {
        stamps = [[NSMutableArray alloc] init];
    }
    
    [stamps addObject:stamp];
    self.monthStamps[[NSString stringWithFormat:@"%lu-%lu", year, month]] = stamps;
    
    [self saveChanges];
}

- (void)deleteStamp:(SRMStamp *)stamp forYear:(NSInteger)year month:(NSInteger)month
{
    NSMutableArray *stamps = [[self monthStampsForYear:year month:month] mutableCopy];
    [stamps removeObject:stamp];
    self.monthStamps[[NSString stringWithFormat:@"%lu-%lu", year, month]] = stamps;
    
    [self saveChanges];
}

#pragma mark - File

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"item.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.monthStamps toFile:path];
}


@end
