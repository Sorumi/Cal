//
//  SRMCalendarThemeManager.m
//  Cal
//
//  Created by Sorumi on 16/8/18.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMCalendarThemeStore.h"

@interface SRMCalendarThemeStore ()

@property (nonatomic, strong) NSMutableArray<NSString *> *themePath;

@property (nonatomic, strong) NSMutableDictionary *monthThemes;

@end

@implementation SRMCalendarThemeStore

#pragma mark - Properties

- (NSMutableArray<NSString *> *)allThemePath
{
    return self.themePath;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMCalendarThemeStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[SRMCalendarThemeStore alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMCalendarThemeStore sharedManager]"
                                 userInfo:nil];
}

- (instancetype)initPrivate
{
    self = [super init];
    if (!_themePath) {
        _themePath = [[NSMutableArray alloc] init];
    }
    [self getPNGPath];
    
    NSString *path = [self itemArchivePath];
    _monthThemes = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (!_monthThemes) {
        _monthThemes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Private

- (void)getPNGPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Theme" ofType:@"bundle"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    
    while((path = [enumerator nextObject]) != nil) {
        [_themePath addObject:path];
    }
}

- (void)loadTheme:(NSString *)theme
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Theme" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    
    NSError *error;
    NSDictionary *styleDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
//    self.styles = styleDic[theme];
//    if (!jsonData || error) {
//        NSLog(@"JSON解码失败");
////        return nil;
//    } else {
//            for (NSString *key in jsonObj) {
//                NSString *value = jsonObj[key];
//                NSLog(@"%@", value);
//            }
////        return jsonObj;
//    }
}

#pragma mark - Public

- (UIImage *)themeImageForNum:(NSInteger)num
{
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Theme.bundle/%@", self.themePath[num]]];
    
    return [UIImage imageWithContentsOfFile:imagePath];
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
    
    return [NSKeyedArchiver archiveRootObject:self.monthThemes toFile:path];
}

@end
