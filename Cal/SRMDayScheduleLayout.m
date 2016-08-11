//
//  SRMDayScheduleLayout.m
//  Cal
//
//  Created by Sorumi on 16/8/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "SRMDayScheduleLayout.h"
#import "SRMCalendarTool.h"
#import "SRMDayBoardView.h"
#import "SRMDayScheduleCell.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarViewController.h"

@interface SRMDayScheduleCellAttribute : NSObject

@property (nonatomic) NSInteger index;//第几列
@property (nonatomic) NSInteger num;//占几分之1
@property (nonatomic) CGFloat startY;
@property (nonatomic) CGFloat endY;

+ (instancetype)attributeForIndex:(NSInteger)index num:(NSInteger)num;
- (instancetype)initWithIndex:(NSInteger)index num:(NSInteger)num;

@end

@implementation SRMDayScheduleCellAttribute

+ (instancetype)attributeForIndex:(NSInteger)index num:(NSInteger)num
{
    return [[SRMDayScheduleCellAttribute alloc] initWithIndex:index num:num];
}

- (instancetype)initWithIndex:(NSInteger)index num:(NSInteger)num
{
    self = [super init];
    if (self) {
        _index = index;
        _num = num;
    }
    return self;
}

@end

@interface SRMDayScheduleLayout ()

@property (nonatomic, strong) NSMutableArray<SRMDayScheduleCellAttribute *> *dayScheduleCellAttributes;

@end

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

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [[NSMutableArray alloc] init];
    
    [allAttributes addObject:[self layoutAttributesForDecorationViewOfKind:@"ScheduleBoard" atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    
    // cell
    self.dayScheduleCellAttributes = [[NSMutableArray alloc] init];
    
    UICollectionView *collectionView = self.collectionView;
    
    SRMCalendarViewController *datasource = (SRMCalendarViewController *)collectionView.dataSource;
    NSDate *startDate = datasource.date;
    NSDate *endDate = [[SRMCalendarTool tool] dateByAddingDays:1 toDate:startDate];
    
    NSInteger number = [collectionView numberOfItemsInSection:0];
    
    // SRMDayScheduleCellAttribute
    for (NSInteger i=0; i<number; i++) {
        EKEvent *event = [datasource dayEventForRow:i];
        SRMDayScheduleCellAttribute *srmAttribute = [SRMDayScheduleCellAttribute attributeForIndex:1 num:1];
        
//        NSLog(@"%@ %@ %@ %@", event.title, event.startDate, event.endDate, event.occurrenceDate);
        
        if ([event.startDate timeIntervalSinceDate:startDate] < 0) {
            srmAttribute.startY = 0;
        } else {
            srmAttribute.startY = [[SRMCalendarTool tool] hourOfDate:event.startDate] * SRMDayBoardCellHeight + (CGFloat)[[SRMCalendarTool tool] miniuteOfDate:event.startDate] / 60 * SRMDayBoardCellHeight;
        }
        
        if ([event.endDate timeIntervalSinceDate:endDate] > 0) {
            srmAttribute.endY = 24 * SRMDayBoardCellHeight;
        } else {
            srmAttribute.endY = [[SRMCalendarTool tool] hourOfDate:event.endDate] * SRMDayBoardCellHeight + (CGFloat)[[SRMCalendarTool tool] miniuteOfDate:event.endDate] / 60 * SRMDayBoardCellHeight;
        }
        
        [self.dayScheduleCellAttributes addObject:srmAttribute];
    }
    
    //
    
    for (NSInteger i=0; i<number ; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        
        [allAttributes addObject:layoutAttributes];
    }
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat leftMargin = 46;
    CGFloat rightMargin = 10;
//    CGFloat cellSpacing = 10;
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

//    SRMCalendarViewController *datasource = (SRMCalendarViewController *)self.collectionView.dataSource;
//    EKEvent *event = [datasource eventForRow:indexPath.row];
//    
//    
//    NSDate *startDate = datasource.date;
//    NSDate *endDate = [[SRMCalendarTool tool] dateByAddingDays:1 toDate:startDate];
//    
//    CGFloat originY;
//    CGFloat height;
//    
//    if ([event.startDate timeIntervalSinceDate: startDate] < 0) {
//        originY = 0;
//    } else {
//        originY = [[SRMCalendarTool tool] hourOfDate:event.startDate] * SRMDayBoardCellHeight + (CGFloat)[[SRMCalendarTool tool] miniuteOfDate:event.startDate] / 60 * SRMDayBoardCellHeight;
//    }
//    
//    if ([event.endDate timeIntervalSinceDate: endDate] > 0) {
//        height = 24 * SRMDayBoardCellHeight - originY;
//    } else {
//        height = [[SRMCalendarTool tool] hourOfDate:event.endDate] * SRMDayBoardCellHeight + (CGFloat)[[SRMCalendarTool tool] miniuteOfDate:event.endDate] / 60 * SRMDayBoardCellHeight - originY;
//    }
//    NSLog(@"cell: %f %f", originY, height);
    
    
    SRMDayScheduleCellAttribute *attr = self.dayScheduleCellAttributes[indexPath.row];
    attributes.frame = CGRectMake(leftMargin, attr.startY, width - leftMargin - rightMargin, MAX(attr.endY-attr.startY, 60)-10);
    
//    NSLog(@"%f %f", attr.startY, attr.endY);
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    layoutAttributes.frame = CGRectMake(0.0, 0.0, self.collectionViewContentSize.width, self.collectionViewContentSize.height);
    layoutAttributes.zIndex = -1;
    return layoutAttributes;
}

@end
