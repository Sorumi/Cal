//
//  SRMStampCell.m
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMStampCell.h"
#import "SRMStampStore.h"

@interface SRMStampCell ()

@property (weak, nonatomic) IBOutlet UIImageView *stampImageView;

@end

@implementation SRMStampCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setStamp:(NSInteger)num
{
    self.stampImageView.image = [[SRMStampStore sharedStore] stampForNum:num];
}

@end
