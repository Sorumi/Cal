//
//  SRMAppearanceViewLayout.m
//  Cal
//
//  Created by Sorumi on 16/8/16.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMAppearanceViewLayout.h"

@interface SRMAppearanceViewLayout ()

@property (nonatomic) CGFloat viewWidth;
@property (nonatomic) CGFloat viewHeight;
@property (nonatomic) NSInteger column;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat pageSpacing;

@end

@implementation SRMAppearanceViewLayout

- (void)prepareLayout
{
    _viewWidth = self.collectionView.frame.size.width;
    _viewHeight = self.collectionView.frame.size.height;
    _itemWidth = _viewHeight / 3;
    _column = _viewWidth / _itemWidth;
    _pageSpacing = (_viewWidth-_itemWidth*_column) / 2;
    _page = [self.collectionView numberOfItemsInSection:0] / 3 / _column + 1;
    
    [self.delegate didPrepareLayout:self];
}

- (CGSize)collectionViewContentSize
{
    CGFloat width = _page * _viewWidth;
    return CGSizeMake(width, _viewHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* answer = [[NSMutableArray alloc] init];
    
    NSInteger firstCol = rect.origin.x / (_viewWidth / _column);
    NSInteger lastCol = (rect.origin.x + rect.size.width) / (_viewWidth / _column) + 1;
    NSInteger num = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i=firstCol; i<lastCol; i++) {
        NSInteger page = i / _column;
        NSInteger row = page * _column * 3 + i%_column;
        for (NSInteger i=0; i<3; i++) {
            if (row+i*_column < num) {
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row+i*_column inSection:0];
                UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexpath];
                [answer addObject:attributes];
            }
        }
    }
    
    return answer;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat xPageOffset = attributes.indexPath.item / 3 /_column * _viewWidth + _pageSpacing;
    CGFloat xCellOffset = xPageOffset + (attributes.indexPath.item % _column) * _itemWidth;
    CGFloat yCellOffset = (attributes.indexPath.item / _column % 3) * _itemWidth;
    attributes.frame = CGRectMake(xCellOffset, yCellOffset, _itemWidth, _itemWidth);

    return attributes;
}


@end

