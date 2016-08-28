//
//  NSString+IconFont.m
//  Cal
//
//  Created by Sorumi on 16/8/19.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "NSString+IconFont.h"

@implementation NSString (IconFont)

#pragma mark - Public API

+ (NSString*)iconfontIconStringForEnum:(IFIcon)value {
    return [NSString iconfontUnicodeStrings][value];
}

#pragma mark - Data Initialization

+ (NSArray *)iconfontUnicodeStrings {
    
    static NSArray *fontAwesomeUnicodeStrings;
    
    static dispatch_once_t unicodeStringsOnceToken;
    
    dispatch_once(&unicodeStringsOnceToken, ^{
        
        fontAwesomeUnicodeStrings =@[@"\U0000e600", @"\U0000e601", @"\U0000e602", @"\U0000e603", @"\U0000e604", @"\U0000e605", @"\U0000e606", @"\U0000e607", @"\U0000e608", @"\U0000e609", @"\U0000e60A", @"\U0000e60B", @"\U0000e60C", @"\U0000e60D", @"\U0000e60E", @"\U0000e60F", @"\U0000e610", @"\U0000e611"];
        });
        
    return fontAwesomeUnicodeStrings;
}



@end
