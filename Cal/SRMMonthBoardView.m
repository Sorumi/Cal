//
//  SRMMonthBoardView.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "ColorUtils.h"
#import "SRMMonthBoardView.h"
#import "SRMMonthBoardViewLayout.h"
#import "SRMBoardStampCell.h"
#import "SRMStamp.h"
#import "SRMStampStore.h"

#import "SRMThemeStore.h"

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
    
    //gesture
    UITapGestureRecognizer *tapBlank = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlank:)];
    self.boardCollectionView.backgroundView = [[UIView alloc] initWithFrame:self.boardCollectionView.frame];
    [self.boardCollectionView.backgroundView addGestureRecognizer:tapBlank];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width = self.frame.size.width;
    CGFloat space = width / 7;
    CGFloat height = space * 6;
    // line
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, _horizontalBorderColor.CGColor);
    
    CGContextSetLineWidth(context, 0.5f);
    for (int i=0; i<=6; i++) {
        CGFloat y = space * i;
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, width, y);
    }
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, _verticalBorderColor.CGColor);
    for (int i=0; i<=7; i++) {
        CGFloat x = space * i;
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x, height);
    }
    
    CGContextStrokePath(context);
}

#pragma mark - Theme Properties

//-(void)setHorizontalBorderColor:(UIColor *)horizontalBorderColor
//{
//    _horizontalBorderColor = horizontalBorderColor;
//    [self setNeedsDisplay];
//}
//
//-(void)setVerticalBorderColor:(UIColor *)verticalBorderColor
//{
//    _verticalBorderColor = verticalBorderColor;
//    [self setNeedsDisplay];
//}

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

- (void)updateThemeAnimate:(BOOL)isAnimate
{
    NSDictionary *theme = [[SRMThemeStore sharedStore] monthThemesForYear:_year month:_month];
    _horizontalBorderColor = [UIColor colorWithString:theme[@"MonthHorizontalBorderColor"]];
    _verticalBorderColor = [UIColor colorWithString:theme[@"MonthVerticalBorderColor"]];

    [self setNeedsDisplay];
    if (isAnimate) {
        [UIView transitionWithView:self
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.layer displayIfNeeded];
                        }
                        completion:nil];
    }
   
}

- (void)deleteStamp:(SRMStamp *)stamp
{
    [[SRMStampStore sharedStore] deleteStamp:stamp forYear:_year month:_month];
}

#pragma mark - Action

- (void)tapBlank:(UITapGestureRecognizer *)gesture
{
//    NSLog(@"%lu", [self.boardCollectionView indexPathsForSelectedItems].count);
    for (NSIndexPath *indexPath in [self.boardCollectionView indexPathsForSelectedItems]) {
        SRMBoardStampCell *cell = (SRMBoardStampCell *)[self.boardCollectionView cellForItemAtIndexPath:indexPath];
        [cell setEditMode:NO];
    }
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
