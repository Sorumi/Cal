//
//  SRMMonthBoardView.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMMonthBoardView.h"
#import "SRMMonthBoardViewLayout.h"
#import "SRMBoardStampCell.h"
#import "SRMStamp.h"
#import "SRMStampStore.h"

@interface SRMMonthBoardView () <UICollectionViewDataSource, UICollectionViewDelegate, SRMMonthBoardViewLayoutDelegate>

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;

@end

@implementation SRMMonthBoardView

static NSString * const reuseBoardStampCellIdentifier = @"BoardStampCell";

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.2];
    
    [self.boardCollectionView registerNib:[UINib nibWithNibName:@"SRMBoardStampCell" bundle:nil] forCellWithReuseIdentifier:reuseBoardStampCellIdentifier];
    
    self.boardCollectionView.dataSource = self;
    self.boardCollectionView.delegate = self;
    SRMMonthBoardViewLayout *layout = (SRMMonthBoardViewLayout *)self.boardCollectionView.collectionViewLayout;
    layout.delegate = self;
}

#pragma mark - Public

- (void)setEditMode:(BOOL)isEditMode
{
    if (isEditMode) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.2];
        
    } else {
        self.userInteractionEnabled = NO;
        self.backgroundColor = nil;
    }
}

- (void)setYear:(NSInteger)year month:(NSInteger)month
{
    _year = year;
    _month = month;
}

- (void)deleteStamp:(SRMStamp *)stamp
{
    [[SRMStampStore sharedStore] deleteStamp:stamp forYear:_year month:_month];
}

#pragma mark - <SRMMonthBoardViewLayoutDelegate>

- (SRMStamp *)stampAtIndexPath:(NSIndexPath *)indexPath
{
    return [[SRMStampStore sharedStore] monthStampsForYear:_year month:_month][indexPath.row];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *stamps = [[SRMStampStore sharedStore] monthStampsForYear:_year month:_month];
    return stamps.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRMBoardStampCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseBoardStampCellIdentifier forIndexPath:indexPath];
    NSArray *stamps = [[SRMStampStore sharedStore] monthStampsForYear:_year month:_month];
    SRMStamp *stamp = stamps[indexPath.row];
    [cell setStamp:stamp];
    [cell setEditMode:NO];
    
    cell.selected = YES;
    [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRMBoardStampCell *cell = (SRMBoardStampCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setEditMode:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRMBoardStampCell *cell = (SRMBoardStampCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setEditMode:NO];
}


@end
