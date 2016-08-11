//
//  SRMStampView.h
//  Cal
//
//  Created by Sorumi on 16/8/11.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SRMStamp;

@interface SRMStampView : UIView

- (instancetype)initWithStamp:(SRMStamp *)stamp image:(UIImage *)image x:(CGFloat)x y:(CGFloat)y;

@end
