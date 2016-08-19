//
//  SRMStampCell.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMAppearanceCell.h"
#import "SRMStampStore.h"
#import "SRMThemeStore.h"

@interface SRMAppearanceCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SRMAppearanceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setStamp:(NSInteger)num
{
    self.imageView.image = [[SRMStampStore sharedStore] stampForNum:num];
}

- (void)setTheme:(NSInteger)num
{
    self.imageView.image = [[SRMThemeStore sharedStore] themeImageForNum:num];
}

@end
