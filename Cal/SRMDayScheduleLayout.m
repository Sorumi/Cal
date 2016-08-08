//
//  SRMDayScheduleLayout.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMDayScheduleLayout.h"
#import "SRMDayBoardView.h"
#import "SRMCalendarConstance.h"

@implementation SRMDayScheduleLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerClass:[SRMDayBoardView class] forDecorationViewOfKind:@"ScheduleBoard"];
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.frame.size.width, SRMDayBoardCellHeight*24);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    layoutAttributes.frame = CGRectMake(0.0, 0.0, self.collectionViewContentSize.width, self.collectionViewContentSize.height);
    layoutAttributes.zIndex = -1;
    return layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [[NSMutableArray alloc] init];
    
    [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"ScheduleBoard" atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    
//    for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++)
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
//        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
//        [allAttributes addObject:layoutAttributes];
//    }
    return allAttributes;
}

@end
