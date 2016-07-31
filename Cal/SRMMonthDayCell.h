//
//  SRMMonthDayCell.h
//  Cal
//
//  Created by Sorumi on 16/7/24.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SRMMonthDayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) NSDate *date;

- (void)setCurrentMonthDate:(NSInteger)day;
- (void)setOtherMonthDate:(NSInteger)day;

@end
