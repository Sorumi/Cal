//
//  SRMCalendarViewController.m
//  Cal
//
//  Created by Sorumi on 16/7/27.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMCalendarViewController.h"
#import "SRMMonthDayCell.h"
#import "SRMMonthViewFlowLayout.h"
#import "SRMCalendarTool.h"
#import "SRMMonthHeaderView.h"

@interface SRMCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) CGFloat const viewWidth;

@property (nonatomic, strong) SRMCalendarTool *tool;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic) NSInteger selectedDay;

@property (weak, nonatomic) IBOutlet SRMMonthHeaderView *headerView;
@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

#pragma mark - Animation

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthViewTop;

@end

@implementation SRMCalendarViewController

static NSString * const reuseCellIdentifier = @"MonthDateCell";

#pragma mark - Properties


- (void)setDate:(NSDate *)date
{
    _date = date;
    self.selectedYear = [_tool yearOfDate:self.date];
    self.selectedMonth = [_tool monthOfDate:self.date];
    self.selectedDay = [_tool dayOfDate:self.date];
}

#pragma mark - Life Cycle & Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    _tool = [[SRMCalendarTool alloc] init];
    self.date = [NSDate date];

//    NSLog(@"%lu %lu %lu", _selectedYear, _selectedMonth, _selectedDay);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view reloadInputViews];
    
    //const
    self.viewWidth = self.view.frame.size.width;

    [self.monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthDayCell" bundle:nil] forCellWithReuseIdentifier:reuseCellIdentifier];
//    [self.monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthClipboardView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseClipboardIdentifier];
    
    self.monthCollectionView.bounces = NO;
    
    self.monthCollectionView.pagingEnabled = YES;
    self.monthCollectionView.showsVerticalScrollIndicator = NO;
    self.monthCollectionView.showsHorizontalScrollIndicator = NO;
    
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;
    
    [self.view bringSubviewToFront:self.headerView];
    
    // add custum gesture
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(MonthToWeek:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.monthCollectionView addGestureRecognizer:swipe];
    
    self.isFirstTimeViewDidLayoutSubviews = YES;

}

- (void)viewDidLayoutSubviews
{
    if (self.isFirstTimeViewDidLayoutSubviews) {
        
        [self scrollToDate:self.date animated:NO];
        self.headerView.dateLabel.text = [NSString stringWithFormat:@"%ld %ld", self.selectedYear, self.selectedMonth];
        self.isFirstTimeViewDidLayoutSubviews = NO;
    }
}

#pragma mark - Private

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = self.tool;
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        NSInteger monthCount = [tool monthsFromDate:tool.minimumDate toDate:date];
        CGFloat offsetX = self.viewWidth * monthCount;
        [self.monthCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    }
}


#pragma mark - Action

- (IBAction)setPrevMonth:(id)sender
{
    NSDate *date = [self.tool dateByAddingMonths:-1 toDate:self.date];
    [self scrollToDate:date animated:YES];
}

- (IBAction)setNextMonth:(id)sender
{
    NSDate *date = [self.tool dateByAddingMonths:1 toDate:self.date];
    [self scrollToDate:date animated:YES];
}

- (void)MonthToWeek:(UISwipeGestureRecognizer *)gesture
{
    [self.view bringSubviewToFront:self.headerView];
    self.monthViewTop.constant = - self.monthCollectionView.frame.size.height + self.viewWidth / 7;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger page = round(self.monthCollectionView.contentOffset.x / self.viewWidth);
    
    SRMCalendarTool *tool = self.tool;
    NSDate *date = [tool dateByAddingMonths:page toDate:tool.minimumDate];
    self.date = date;
    self.selectedYear = [tool yearOfDate:self.date];
    self.selectedMonth = [tool monthOfDate:self.date];
    self.selectedDay = [tool dayOfDate:self.date];
    
    self.headerView.dateLabel.text = [NSString stringWithFormat:@"%ld %ld", self.selectedYear, self.selectedMonth];
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    SRMCalendarTool *tool = self.tool;
    return [tool monthsFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SRMMonthDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    
    SRMCalendarTool *tool = self.tool;
    
    NSDate *date = [tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate];

    NSInteger blankDayCount = [self.tool weekdayOfDate:[self.tool beginningOfMonthOfDate:date]];
    NSInteger currentMonthDayCount = [self.tool dayCountOfMonthofDate:date];
    
    date = [tool dateByAddingMonths:-1 toDate:date];
    NSInteger previousMonthDayCount = [self.tool dayCountOfMonthofDate:date];

    if (indexPath.row < blankDayCount) {
        [cell setOtherMonthDate:previousMonthDayCount - blankDayCount + indexPath.row + 1];
        
    } else if (indexPath.row > blankDayCount + currentMonthDayCount - 1) {
        [cell setOtherMonthDate:indexPath.row - blankDayCount - currentMonthDayCount + 1];
        
    } else {
        [cell setCurrentMonthDate:indexPath.row - blankDayCount + 1];
    }
 
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 0.3;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = self.viewWidth / 7.0;
    CGSize size = CGSizeMake(cellWidth, cellWidth);

    return size;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *reusableview = nil;
//    
//    if (kind == UICollectionElementKindSectionHeader)
//    {
//        SRMMonthClipboardView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseClipboardIdentifier forIndexPath:indexPath];
//        reusableview = headerView;
//    }
//    
//    return reusableview;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark - Others
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

@end
