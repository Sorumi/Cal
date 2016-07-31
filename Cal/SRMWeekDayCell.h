//
//  SRMWeekDayCell.h
//  Cal
//
//  Created by Sorumi on 16/7/29.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMWeekDayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) NSDate *date;

- (void)setWeekDate:(NSInteger)day;

@end
