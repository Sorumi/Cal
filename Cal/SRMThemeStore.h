//
//  SRMThemeStore.h
//  Cal
//
//  Created by Sorumi on 16/8/18.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMThemeStore : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *allThemePath;

+ (instancetype)sharedStore;

- (UIImage *)themeImageForNum:(NSInteger)num;

- (NSDictionary *)monthThemesForYear:(NSInteger)year month:(NSInteger)month;
- (void)setTheme:(NSInteger)num forYear:(NSInteger)year month:(NSInteger)month;
- (void)setCurrentThemeYear:(NSInteger)year month:(NSInteger)month;

- (UIColor *)colorForName:(NSString *)name;
- (UIColor *)colorOfTheme:(NSDictionary *)theme forName:(NSString *)name;

@end
