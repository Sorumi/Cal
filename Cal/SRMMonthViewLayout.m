//
//  SRMMonthViewLayout.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthViewLayout.h"
#import "SRMCalendarTool.h"
#import "SRMStampStore.h"
#import "SRMStamp.h"

@interface SRMMonthViewLayout ()

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat viewWidth;
@property (nonatomic) CGFloat viewHeight;
//@property (nonatomic, strong) NSMutableArray *layoutAttributes;

@end

@implementation SRMMonthViewLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _viewWidth = [UIScreen mainScreen].bounds.size.width;
        _viewHeight = _viewWidth / 7 * 6;
        _itemSize = CGSizeMake(_viewWidth/7, _viewWidth/7);
//        _layoutAttributes = [[NSMutableArray alloc] init];

    }
    return self;
}

//- (void)prepareLayout
//{
//    [super prepareLayout];
//     NSInteger page = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
//    for (int i=0; i<page; i++) {
//        for (int j=0; j<42; j++) {
//            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:j inSection:i];
//            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexpath];
//            [_layoutAttributes addObject:attributes];
//        }
//        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
//        [_layoutAttributes addObject:attributes];
//    }
//}

- (CGSize)collectionViewContentSize
{
    NSInteger page = [self.collectionView numberOfSections];
    return CGSizeMake(self.viewWidth * page, self.viewHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* answer = [[NSMutableArray alloc] init];

    NSInteger firstRow = rect.origin.x / (self.viewWidth / 7);
    NSInteger lastRow = (rect.origin.x + rect.size.width) / (self.viewWidth / 7) + 1;
    for (NSInteger i=firstRow; i<lastRow; i++) {
        NSInteger section = i/7;
        NSInteger row = i%7;
        for (NSInteger i=row; i<42; i=i+7) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:section];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexpath];
            [answer addObject:attributes];
        }
    }
    
    NSInteger firstSection = rect.origin.x / self.viewWidth ;
    NSInteger lastSection = (rect.origin.x + rect.size.width) / self.viewWidth ;
    for (NSInteger i=firstSection; i<=lastSection; i++) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        [answer addObject:attributes];
    }
    return answer;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    UICollectionView *collectionView = self.collectionView;
    
    CGFloat xPageOffset = attributes.indexPath.section * collectionView.frame.size.width;
    CGFloat xCellOffset = xPageOffset + (attributes.indexPath.item % 7) * self.itemSize.width;
    CGFloat yCellOffset = (attributes.indexPath.item / 7) * self.itemSize.width;
    attributes.frame = CGRectMake(xCellOffset, yCellOffset, self.itemSize.width, self.itemSize.height);
    attributes.zIndex = indexPath.row;
    
    return attributes;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (elementKind == UICollectionElementKindSectionHeader) {
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        
        UICollectionView *collectionView = self.collectionView;
        CGFloat xPageOffset = attributes.indexPath.section * collectionView.frame.size.width;
        attributes.frame = CGRectMake(xPageOffset, 0, self.viewWidth, self.viewHeight);
        attributes.zIndex = 99;
        return attributes;
    }
    return nil;
}

@end
