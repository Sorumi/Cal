//
//  SRMCalendarThemeManager.h
//  Cal
//
//  Created by Sorumi on 16/8/18.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRMCalendarThemeStore : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *allThemePath;

+ (instancetype)sharedStore;

- (UIImage *)themeImageForNum:(NSInteger)num;

@end
