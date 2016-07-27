//
//  SRMMonthViewController.m
//  Cal
//
//  Created by Sorumi on 16/7/24.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRMMonthViewController.h"
#import "SRMMonthDayCell.h"
#import "SRMMonthViewFlowLayout.h"
#import "SRMCalendarTool.h"
#import "SRMMonthHeaderView.h"

@interface SRMMonthViewController ()

@property (nonatomic, strong) SRMCalendarTool *tool;
@property (nonatomic) NSUInteger selectedYear;
@property (nonatomic) NSUInteger selectedMonth;

@end

@implementation SRMMonthViewController

static NSString * const reuseIdentifier = @"MonthDateCell";

#pragma mark - Properties

- (SRMCalendarTool *)tool
{
    if (!_tool) {
        _tool = [[SRMCalendarTool alloc] init];
        self.selectedYear = _tool.components.year;
        self.selectedMonth = _tool.components.month;
    }
    return _tool;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view reloadInputViews];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[SRMMonthDayCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    
    self.collectionView.pagingEnabled = YES;
    //让collectionView隐藏水平、垂直滚动条，这个可以根据对应需求自己设置
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    //让collectionView隐藏弹簧效果
//    self.collectionView.bounces = NO;
//    self.collectionView.allowsMultipleSelection = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action

- (IBAction)setPrevMonth:(id)sender {

    if (self.selectedMonth > 1) {
        self.selectedMonth--;
    } else {
        self.selectedYear--;
        self.selectedMonth = 12;
    }
    self.tool.components.month = self.selectedMonth;
    self.tool.components.year = self.selectedYear;
    [self.collectionView reloadData];
    
}

- (IBAction)setNextMonth:(id)sender {
    
    if (self.selectedMonth <12) {
        self.selectedMonth++;
    } else {
        self.selectedYear++;
        self.selectedMonth = 1;
    }
    self.tool.components.month = self.selectedMonth;
    self.tool.components.year = self.selectedYear;
    [self.collectionView reloadData];

}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger days = [self.tool firstWeekDay] + [self.tool dayCount];
    NSUInteger row = days / 7 + (days % 7 == 0 ? 0 : 1 );
    return row * 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SRMMonthDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSUInteger blankDayCount = [self.tool firstWeekDay];
    NSUInteger dayCount = [self.tool dayCount];
    
    if (indexPath.row < blankDayCount || indexPath.row > blankDayCount + dayCount - 1) {
        cell.dateLabel.text = @"";
    } else {
        cell.dateLabel.text = [NSString stringWithFormat:@"%lu", indexPath.row - blankDayCount + 1];
    }

    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 0.5;
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        SRMMonthHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MonthHeader" forIndexPath:indexPath];
        header.dateLabel.text = [[NSString alloc] initWithFormat:@"%lu年%lu月", self.selectedYear, self.selectedMonth];
        
        return header;
    }
    else
        return nil;
}


#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.frame.size.width;
    CGFloat cellWidth = (width) / 7.0;
    CGSize size = CGSizeMake(cellWidth, cellWidth);
    CGSize newFrame = self.collectionView.contentSize;
    newFrame.height = 6*cellWidth + 70;
    self.collectionView.contentSize = newFrame;
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
