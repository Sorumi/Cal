//
//  SRMWeekViewFlowLayout.m
//  Cal
//
//  Created by Sorumi on 16/7/29.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMWeekViewFlowLayout.h"

@interface SRMWeekViewFlowLayout ()

@property (nonatomic) CGFloat viewWidth;
@property (nonatomic) CGFloat viewHeight;

@end

@implementation SRMWeekViewFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _viewWidth = [UIScreen mainScreen].bounds.size.width;
        _viewHeight = _viewWidth / 7 ;
        
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.minimumLineSpacing = 0;
        self.minimumInteritemSpacing = 0;
        
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (CGSize)itemSize
{
    CGFloat width = self.collectionView.frame.size.width / 7;
    return CGSizeMake(width, width);
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    UICollectionView *collectionView = self.collectionView;
    
    CGFloat xPageOffset = attributes.indexPath.section * collectionView.frame.size.width;
    CGFloat xCellOffset = xPageOffset + (attributes.indexPath.item % 7) * self.itemSize.width;
    attributes.frame = CGRectMake(xCellOffset, -0.1, self.itemSize.width, self.itemSize.height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [super layoutAttributesForItemAtIndexPath:indexPath].copy;
    [self applyLayoutAttributes:attrs];
    return attrs;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect].copy];
    NSMutableArray* answer = [[NSMutableArray alloc] init];
    
    for (UICollectionViewLayoutAttributes *attr in attributes) {
        if (attr.representedElementCategory == UICollectionElementCategoryCell) {
            UICollectionViewLayoutAttributes *newAttr = [self layoutAttributesForItemAtIndexPath:attr.indexPath];
            [answer addObject:newAttr];
        }
    }
    return answer;
}

@end
