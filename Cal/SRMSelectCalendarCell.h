//
//  SRMSelectCalendarCell.h
//  Cal
//
//  Created by Sorumi on 16/8/27.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMSelectCalendarCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;

@property (nonatomic, copy) void (^buttonAction)();

@end
