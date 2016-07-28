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

@property (nonatomic, strong) SRMCalendarTool *tool;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic) NSInteger selectedDay;

@property (weak, nonatomic) IBOutlet SRMMonthHeaderView *headerView;

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@end

@implementation SRMCalendarViewController

static NSString * const reuseIdentifier = @"MonthDateCell";

#pragma mark - Properties


//- (void)setSelectedMonth:(NSUInteger)selectedMonth
//{
//    _selectedMonth = selectedMonth;
//    self.headerView.dateLabel.text = [NSString stringWithFormat:@"%lu %lu", _selectedYear, _selectedMonth];
//}
//
//- (void)setSelectedYear:(NSUInteger)selectedYear
//{
//    _selectedYear = selectedYear;
//    self.headerView.dateLabel.text = [NSString stringWithFormat:@"%lu %lu", _selectedYear, _selectedMonth];
//}

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
//    SRMMonthViewFlowLayout *layout = [[SRMMonthViewFlowLayout alloc] init];
//    CGFloat width = self.view.frame.size.width;
//    CGRect frame = CGRectMake(-width, 70, width * 3, width / 7 * 6);
//    self.monthCollectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
//    [self.view addSubview:self.monthCollectionView];
//    
    _tool = [[SRMCalendarTool alloc] init];
    _date = [NSDate date];
    _selectedMonth = [_tool monthOfDate:_date];
    _selectedYear = [_tool yearOfDate:_date];
    _selectedDay = [_tool dayOfDate:_date];
    
    NSLog(@"%d %d %d", _selectedYear, _selectedMonth, _selectedDay);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view reloadInputViews];
    
    
//    [self.monthCollectionView registerClass:[SRMMonthDayCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthDayCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.monthCollectionView.bounces = NO;
    
    self.monthCollectionView.pagingEnabled = YES;
    self.monthCollectionView.showsVerticalScrollIndicator = NO;
    self.monthCollectionView.showsHorizontalScrollIndicator = NO;
    
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;

    self.isFirstTimeViewDidLayoutSubviews = YES;

}

- (void)viewDidLayoutSubviews
{
    if (self.isFirstTimeViewDidLayoutSubviews) {
        
        SRMCalendarTool *tool = self.tool;
//        NSDate *date = [tool dateWithYear:self.selectedYear month:self.selectedMonth day:self.selectedDay];
//        NSInteger monthCount = [tool monthsFromDate:tool.minimumDate toDate:date];
//        
//        CGFloat width = self.view.frame.size.width * monthCount;
//        [self.monthCollectionView setContentOffset:CGPointMake(width, 0) animated:NO];
        [self scrollToDate:self.date animated:NO];
        self.isFirstTimeViewDidLayoutSubviews = NO;
    }
}

#pragma mark - Private

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = self.tool;
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        NSInteger monthCount = [tool monthsFromDate:tool.minimumDate toDate:date];
        CGFloat offsetX = self.view.frame.size.width * monthCount;
        [self.monthCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    }
}

- (void)scrollToDateDidEnd
{
    CGFloat width = self.view.frame.size.width;
    NSInteger page = self.monthCollectionView.contentOffset.x / width;
    
    SRMCalendarTool *tool = self.tool;
    NSDate *date = [tool dateByAddingMonths:page toDate:tool.minimumDate];
    self.date = date;
    self.selectedYear = [tool yearOfDate:self.date];
    self.selectedMonth = [tool monthOfDate:self.date];
    self.selectedDay = [tool dayOfDate:self.date];
    NSLog(@"%lu %lu %lu", self.selectedYear, self.selectedMonth, self.selectedDay);
    self.date = date;
    self.headerView.dateLabel.text = [NSString stringWithFormat:@"%ld %ld", self.selectedYear, self.selectedMonth];
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

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat width = self.view.frame.size.width;
    NSInteger page = round(self.monthCollectionView.contentOffset.x / width);
    
    SRMCalendarTool *tool = self.tool;
    NSDate *date = [tool dateByAddingMonths:page toDate:tool.minimumDate];
    self.date = date;
    self.selectedYear = [tool yearOfDate:self.date];
    self.selectedMonth = [tool monthOfDate:self.date];
    self.selectedDay = [tool dayOfDate:self.date];
//    NSLog(@"%lu %lu %lu", self.selectedYear, self.selectedMonth, self.selectedDay);
    self.date = date;
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
    SRMMonthDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SRMCalendarTool *tool = self.tool;
    
    NSInteger month = [tool monthOfDate:[tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate]];
    
    NSDate *date = [self.tool dateWithYear:self.selectedYear month:month day:self.selectedDay];
    NSInteger blankDayCount = [self.tool weekdayOfDate:[self.tool beginningOfMonthOfDate:date]];
    NSInteger dayCount = [self.tool dayCountOfMonthofDate:date];
    
//    NSLog(@"%lu %lu", blankDayCount, dayCount);

    if (indexPath.row < blankDayCount || indexPath.row > blankDayCount + dayCount - 1) {
        cell.dateLabel.text = @"";
    } else {
        cell.dateLabel.text = [NSString stringWithFormat:@"%lu", indexPath.row - blankDayCount + 1];
    }
 
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.layer.borderWidth = 0.3;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = collectionView.frame.size.width;
    CGFloat cellWidth = (width) / 7.0;
    CGSize size = CGSizeMake(cellWidth, cellWidth);

    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
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
