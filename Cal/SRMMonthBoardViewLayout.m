//
//  SRMMonthBoardViewLayout.m
//  Cal
//
//  Created by Sorumi on 16/8/13.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthBoardViewLayout.h"
#import "SRMStamp.h"
#import "SRMStampStore.h"

@interface SRMMonthBoardViewLayout ()

@property (nonatomic, strong) NSMutableArray *layoutAttributes;

@end

@implementation SRMMonthBoardViewLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    _layoutAttributes = [[NSMutableArray alloc] init];
    NSInteger num = [self.collectionView numberOfItemsInSection:0];
    for (int i=0; i<num; i++) {

        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexpath];
        
        [_layoutAttributes addObject:attributes];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return _layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    UICollectionView *collectionView = self.collectionView;
    
    SRMStamp *stamp = [_delegate stampAtIndexPath:indexPath];

    CGSize imageSize = [[SRMStampStore sharedStore] stampForName:stamp.name].size;
    
    attributes.frame = CGRectMake(0, 0, imageSize.width+12, imageSize.height+12);
    attributes.center = CGPointMake(stamp.xProportion*collectionView.frame.size.width, stamp.yProportion*collectionView.frame.size.height);

    return attributes;
}

@end
