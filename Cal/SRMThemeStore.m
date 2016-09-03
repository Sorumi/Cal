//
//  SRMThemeStore.m
//  Cal
//
//  Created by Sorumi on 16/8/18.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRMThemeStore.h"

#import "ColorUtils.h"

@interface SRMThemeStore ()

@property (nonatomic, strong) NSMutableArray<NSString *> *themePath;

@property (nonatomic, strong) NSMutableDictionary *monthThemes;

@property (nonatomic, strong) NSDictionary *currentTheme;

@end

@implementation SRMThemeStore

#pragma mark - Properties

- (NSMutableArray<NSString *> *)allThemePath
{
    return self.themePath;
}

#pragma mark - Initialization

+ (instancetype)sharedStore
{
    static SRMThemeStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[SRMThemeStore alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[SRMThemeStore sharedManager]"
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

- (NSDictionary *)loadTheme:(NSString *)theme
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Theme" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    
    NSError *error;
    NSDictionary *allThemes = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return allThemes[theme];
}

- (NSDictionary *)monthThemesForYear:(NSInteger)year month:(NSInteger)month
{
    NSString *themeName = self.monthThemes[[NSString stringWithFormat:@"%lu-%lu", year, month]];
    NSDictionary *themeDic = [self loadTheme:themeName];
    return themeDic ? themeDic : [self loadTheme:@"theme_0"];
}

#pragma mark - Public

- (UIImage *)themeImageForNum:(NSInteger)num
{
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Theme.bundle/%@", self.themePath[num]]];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (void)setCurrentThemeYear:(NSInteger)year month:(NSInteger)month
{
    _currentTheme = [self monthThemesForYear:year month:month];
    
}

- (void)setTheme:(NSInteger)num forYear:(NSInteger)year month:(NSInteger)month
{
    NSString *themeName = [self.allThemePath[num] componentsSeparatedByString:@"@"][0];
    self.monthThemes[[NSString stringWithFormat:@"%lu-%lu", year, month]] = themeName;

    [self saveChanges];
    [self setCurrentThemeYear:year month:month];
}

- (UIColor *)colorForName:(NSString *)name
{
    return [UIColor colorWithString:_currentTheme[name]];
}

- (UIColor *)colorOfTheme:(NSDictionary *)theme forName:(NSString *)name
{
    return [UIColor colorWithString:theme[name]];
}

#pragma mark - File

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"monthTheme.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.monthThemes toFile:path];
}

@end
