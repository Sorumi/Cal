//
//  SRMCalendarViewController.m
//  Cal
//
//  Created by Sorumi on 16/7/27.
//  Copyright © 2016年 Sorumi. All rights reserved.
//


#import <EventKit/EventKit.h>
#import "SRMCalendarViewController.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarTool.h"
#import "SRMCalendarHeader.h"
#import "SRMMonthDayCell.h"
#import "SRMWeekDayCell.h"
#import "SRMWeekWeekdayHeader.h"
#import "SRMListHeader.h"
#import "SRMEvent.h"
#import "SRMEventStore.h"
#import "SRMEventCell.h"
#import "SRMTask.h"
#import "SRMTaskStore.h"
#import "SRMTaskCell.h"

@interface SRMCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@property (nonatomic) CGFloat const viewWidth;

@property (nonatomic, strong) SRMCalendarTool *tool;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *today;
@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic) NSInteger selectedDay;

#pragma mark - Collection

@property (nonatomic) SRMCalendarViewMode viewMode;

@property (weak, nonatomic) IBOutlet SRMCalendarHeader *headerView;
@property (weak, nonatomic) IBOutlet SRMWeekWeekdayHeader *weekWeekdayHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *weekCollectionView;

#pragma mark - Table

@property (weak, nonatomic) IBOutlet UITableView *monthItemTableView;

#pragma mark - Constraint

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthWeekdayViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weekViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weekHeaderTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonLeading;

@end

@implementation SRMCalendarViewController

static NSString * const reuseMonthCellIdentifier = @"MonthDateCell";
static NSString * const reuseWeekCellIdentifier = @"WeekDateCell";
static NSString * const reuseEventCellIdentifier = @"EventCell";
static NSString * const reuseTaskCellIdentifier = @"TaskCell";

#pragma mark - Properties

- (void)setDate:(NSDate *)date
{
    _date = date;
    _selectedYear = [_tool yearOfDate:_date];
    _selectedMonth = [_tool monthOfDate:_date];
    _selectedDay = [_tool dayOfDate:_date];
    [self.headerView setWeekHeaderYear:self.selectedYear month:self.selectedMonth day:self.selectedDay weekday:[self.tool weekdayOfDate:self.date]];
    
    if (self.viewMode == SRMCalendarMonthViewMode) {
        [self weekScrollToDate:self.date animated:NO];
        [self.weekWeekdayHeader setCirclePos:[self.tool weekdayOfDate:self.date] animated:NO];
        
    } else if (self.viewMode == SRMCalendarWeekViewMode) {
        [self monthScrollToDate:self.date animated:NO];
        [self.weekWeekdayHeader setCirclePos:[self.tool weekdayOfDate:self.date] animated:YES];
    }
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
    _date = [NSDate date];
    _today = self.date;
    _selectedYear = [_tool yearOfDate:_date];
    _selectedMonth = [_tool monthOfDate:_date];
    _selectedDay = [_tool dayOfDate:_date];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view reloadInputViews];
    
    // const
    self.viewWidth = self.view.frame.size.width;

    // collection
    [self.monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthDayCell" bundle:nil] forCellWithReuseIdentifier:reuseMonthCellIdentifier];
    [self.weekCollectionView registerNib:[UINib nibWithNibName:@"SRMWeekDayCell" bundle:nil] forCellWithReuseIdentifier:reuseWeekCellIdentifier];
    
    self.monthCollectionView.bounces = NO;
    self.monthCollectionView.pagingEnabled = YES;
    self.monthCollectionView.showsVerticalScrollIndicator = NO;
    self.monthCollectionView.showsHorizontalScrollIndicator = NO;
    
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;
    
    self.weekCollectionView.bounces = NO;
    self.weekCollectionView.pagingEnabled = YES;
    self.weekCollectionView.showsVerticalScrollIndicator = NO;
    self.weekCollectionView.showsHorizontalScrollIndicator = NO;
    
    self.weekCollectionView.delegate = self;
    self.weekCollectionView.dataSource = self;
    
    self.viewMode = SRMCalendarMonthViewMode;
    
    // table
    [self.monthItemTableView registerNib:[UINib nibWithNibName:@"SRMEventCell" bundle:nil] forCellReuseIdentifier:reuseEventCellIdentifier];
    [self.monthItemTableView registerNib:[UINib nibWithNibName:@"SRMTaskCell" bundle:nil] forCellReuseIdentifier:reuseTaskCellIdentifier];
    
    self.monthItemTableView.scrollEnabled = NO;
    
    self.monthItemTableView.delegate = self;
    self.monthItemTableView.dataSource = self;
    
    // add custum gesture
    UISwipeGestureRecognizer *monthToWeek = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(monthToWeek:)];
    monthToWeek.direction = UISwipeGestureRecognizerDirectionUp;
    [self.monthCollectionView addGestureRecognizer:monthToWeek];
    
    UISwipeGestureRecognizer *weekToMonth = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(weekToMonth:)];
    weekToMonth.direction = UISwipeGestureRecognizerDirectionDown;
    [self.weekCollectionView addGestureRecognizer:weekToMonth];
    
    UISwipeGestureRecognizer *upMonthItem = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(upMonthItemTable:)];
    upMonthItem.direction = UISwipeGestureRecognizerDirectionUp;
    [self.monthItemTableView addGestureRecognizer:upMonthItem];
    
    self.isFirstTimeViewDidLayoutSubviews = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // event
    
    [[SRMEventStore sharedStore] checkCalendarAuthorizationStatus];
    if ([SRMEventStore sharedStore].isGranted) {
        [[SRMEventStore sharedStore] fetchEventsFromDate:[self.tool dateWithYear:2016 month:1 day:1]
                                                  toDate:[self.tool dateWithYear:2016 month:12 day:31]];
    }
}

- (void)viewDidLayoutSubviews
{
    if (self.isFirstTimeViewDidLayoutSubviews) {
        
        [self monthScrollToDate:self.today animated:NO];
        [self weekScrollToDate:self.today animated:NO];
        [self.headerView setMonthHeaderYear:self.selectedYear month:self.selectedMonth];
        
        self.date = self.today;
        self.isFirstTimeViewDidLayoutSubviews = NO;

    }
}

#pragma mark - Private

- (void)monthScrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = self.tool;
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        NSInteger monthCount = [tool monthsFromDate:tool.minimumDate toDate:date];
        CGFloat offsetX = self.viewWidth * monthCount;
        [self.monthCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
        
    }
}

- (void)weekScrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = self.tool;
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        date = [tool beginningOfWeekOfDate:date];
        NSDate *beginDate = [tool beginningOfWeekOfDate:tool.minimumDate];
        NSInteger weekCount = [tool weeksFromDate:beginDate toDate:date];
        CGFloat offsetX = self.viewWidth * weekCount;
        [self.weekCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    }
}

#pragma mark - Action

- (IBAction)setPrevMonth:(id)sender
{
    NSDate *date = [self.tool dateByAddingMonths:-1 toDate:self.date];
    [self monthScrollToDate:date animated:YES];
}

- (IBAction)setNextMonth:(id)sender
{
    NSDate *date = [self.tool dateByAddingMonths:1 toDate:self.date];
    [self monthScrollToDate:date animated:YES];
}

- (IBAction)backToToday:(id)sender
{
    self.date = self.today;
    if (self.viewMode == SRMCalendarMonthViewMode) {
        [self monthScrollToDate:self.date animated:YES];
    } else if (self.viewMode == SRMCalendarWeekViewMode) {
        [self weekScrollToDate:self.date animated:YES];
    }
}

- (void)monthToWeek:(UISwipeGestureRecognizer *)gesture
{
    if (self.viewMode != SRMCalendarMonthViewMode) {
        return;
    }
    self.viewMode = SRMCalendarWeekViewMode;
    
    // animation
    [self.view bringSubviewToFront:self.headerView];
    self.monthWeekdayViewTop.constant = - self.monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight + self.viewWidth / 7;
    self.weekViewBottom.constant = self.weekCollectionView.frame.size.height;
    self.weekHeaderTrailing.constant = self.headerView.weekHeader.frame.size.width;
    self.backButtonLeading.constant = -42;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.headerView.monthHeader.alpha = 0;
                         self.headerView.weekHeader.alpha = 1;
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

- (void)weekToMonth:(UISwipeGestureRecognizer *)gesture
{
    if (self.viewMode != SRMCalendarWeekViewMode) {
        return;
    }
    self.viewMode = SRMCalendarMonthViewMode;
    
    // animation
    [self.view bringSubviewToFront:self.headerView];
    self.monthWeekdayViewTop.constant = 0;
    self.weekViewBottom.constant = 0;
    self.weekHeaderTrailing.constant = 0;
    self.backButtonLeading.constant = 0;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.headerView.monthHeader.alpha = 1;
                         self.headerView.weekHeader.alpha = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];

}

- (void)upMonthItemTable:(UISwipeGestureRecognizer *)gesture
{
    if (self.viewMode != SRMCalendarMonthViewMode) {
        return;
    }
    self.viewMode = SRMCalendarItemViewMode;
    
    // animation
    [self.view bringSubviewToFront:self.headerView];
    self.monthWeekdayViewTop.constant = - self.monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight;
    self.backButtonLeading.constant = -42;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.headerView.monthHeader.alpha = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             self.monthItemTableView.scrollEnabled = YES;
                         }
                     }];

}

- (void)downMonthItemTable
{
    if (self.viewMode != SRMCalendarItemViewMode) {
        return;
    }
    self.viewMode = SRMCalendarMonthViewMode;
    
    // animation
    [self.view bringSubviewToFront:self.headerView];
    self.monthWeekdayViewTop.constant = 0;
    self.backButtonLeading.constant = 0;
    [self.monthItemTableView setContentOffset:CGPointZero  animated:YES];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.headerView.monthHeader.alpha = 1;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             self.monthItemTableView.scrollEnabled = NO;
                             NSLog(@"%f", self.monthItemTableView.contentOffset.y);
                         }
                     }];
    
}

- (IBAction)backToMode:(id)sender
{
    if (self.viewMode == SRMCalendarWeekViewMode) {
        [self weekToMonth:nil];
    } else if (self.viewMode == SRMCalendarItemViewMode) {
        [self downMonthItemTable];
    }
}

#pragma mark - <UITableViewDateSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
         return [[SRMTaskStore sharedStore] allTasks].count;
        
    } else if (section == 1) {
         return [[SRMEventStore sharedStore] allEvents].count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SRMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTaskCellIdentifier forIndexPath:indexPath];
        NSArray *items = [[SRMTaskStore sharedStore] allTasks];
        SRMTask *item = items[indexPath.row];
        
        [cell setTask:[NSString stringWithFormat:@"%@", item.title]];
        
        return cell;
        
    } else if (indexPath.section == 1) {
        SRMEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseEventCellIdentifier forIndexPath:indexPath];
        NSArray *items = [[SRMEventStore sharedStore] allEvents];
        SRMEvent *item = items[indexPath.row];
        
        [cell setEvent:[NSString stringWithFormat:@"%@", item.systemEvent.title]];
        
        return cell;
    }
    return  nil;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return SRMTaskCellHeight + SRMItemCellSpacing;

    } else if (indexPath.section == 1) {
        return SRMEventCellHeight + SRMItemCellSpacing;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.monthItemTableView) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SRMListHeader" owner:self options:nil];
        SRMListHeader *header = [array firstObject];
        if (section == 0) {
            header.sectionTitleLable.text = @"Tasks";
        } else if (section == 0) {
            header.sectionTitleLable.text = @"Events";
        }
            return header;
    }
    return nil;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //month view change the label
    NSDate *date;
    SRMCalendarTool *tool = self.tool;
    
    if (scrollView == self.monthCollectionView) {
        NSInteger page = round(self.monthCollectionView.contentOffset.x / self.viewWidth);
    
        date = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSInteger year = [tool yearOfDate:date];
        NSInteger month = [tool monthOfDate:date];

        [self.headerView setMonthHeaderYear:year month:month];
        
    } else if (scrollView == self.weekCollectionView) {
    
    }

}

// use finger ti scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.monthCollectionView && self.viewMode == SRMCalendarMonthViewMode) {

        SRMCalendarTool *tool = self.tool;
        NSInteger page = self.monthCollectionView.contentOffset.x / self.viewWidth;
        NSDate *currentBeginningDate = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSDate *selfBeginningDate = [tool beginningOfMonthOfDate:self.date];

        if (![tool date:currentBeginningDate isEqualToDate:selfBeginningDate]) {
            self.date = currentBeginningDate;

        }
        
    } else if (scrollView == self.weekCollectionView && self.viewMode == SRMCalendarWeekViewMode) {
        
        SRMCalendarTool *tool = self.tool;
        NSInteger page = self.weekCollectionView.contentOffset.x / self.viewWidth;
        NSDate *currentBeginningDate = [tool beginningOfWeekOfDate:tool.minimumDate];
        currentBeginningDate = [tool dateByAddingWeeks:page toDate:currentBeginningDate];
        NSDate *selfBeginningDate = [tool beginningOfWeekOfDate:self.date];
        
        if (![tool date:currentBeginningDate isEqualToDate:selfBeginningDate]) {
            self.date = currentBeginningDate;
        }
    }

}

// use code to scroll
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.monthCollectionView && self.viewMode == SRMCalendarMonthViewMode) {

        SRMCalendarTool *tool = self.tool;
        NSInteger page = self.monthCollectionView.contentOffset.x / self.viewWidth;
        NSDate *currentBeginningDate = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSDate *selfBeginningDate = [tool beginningOfMonthOfDate:self.date];
        
        if (![tool date:currentBeginningDate isEqualToDate:selfBeginningDate]) {
            self.date = currentBeginningDate;
        }
        
    }
}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    SRMCalendarTool *tool = self.tool;
    
    if (collectionView == self.monthCollectionView) {
        
        return [tool monthsFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
        
    } else if (collectionView == self.weekCollectionView) {
        
        return [tool weeksFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
    }
    
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.monthCollectionView) {
        
        return 42;
        
    } else if (collectionView == self.weekCollectionView) {
        
        return 7;
        
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.monthCollectionView) {
        SRMMonthDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseMonthCellIdentifier forIndexPath:indexPath];
        
        SRMCalendarTool *tool = self.tool;
        
        NSDate *date = [tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate];
        
        NSInteger blankDayCount = [self.tool weekdayOfDate:[self.tool beginningOfMonthOfDate:date]];
        NSInteger currentMonthDayCount = [self.tool dayCountOfMonthofDate:date];
        
        
        NSDate *prevDate = [tool dateByAddingMonths:-1 toDate:date];
        NSInteger previousMonthDayCount = [self.tool dayCountOfMonthofDate:prevDate];

        date = [tool dateByAddingDays:(indexPath.row - blankDayCount) toDate:date];
        cell.date = date;
        
        if (indexPath.row < blankDayCount) {
            [cell setOtherMonthDate:previousMonthDayCount - blankDayCount + indexPath.row + 1];
            
        } else if (indexPath.row > blankDayCount + currentMonthDayCount - 1) {
            [cell setOtherMonthDate:indexPath.row - blankDayCount - currentMonthDayCount + 1];
            
        } else {
            [cell setCurrentMonthDate:indexPath.row - blankDayCount + 1];
        }
        
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

        return cell;
        
    } else if (collectionView == self.weekCollectionView) {
        SRMWeekDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseWeekCellIdentifier forIndexPath:indexPath];
        
        SRMCalendarTool *tool = self.tool;
        NSDate *date = [tool dateByAddingWeeks:indexPath.section toDate:tool.minimumDate];
        date = [tool beginningOfWeekOfDate:date];
        date = [tool dateByAddingDays:indexPath.row toDate:date];
        
        cell.date = date;
        [cell setWeekDate:[tool dayOfDate:date]];
        
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

        return cell;
    }
    
    return nil;
}

#pragma mark - <UICollectionViewDelegate>


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = self.viewWidth / 7.0;
    CGSize size = CGSizeMake(cellWidth, cellWidth);

    return size;
}

/*
// 允许选中时，高亮
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 高亮完成后回调
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
// 由高亮转成非高亮完成时的回调
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{

}
*/
// 设置是否允许选中
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 设置是否允许取消选中
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 选中操作
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.monthCollectionView) {
        SRMMonthDayCell *cell = (SRMMonthDayCell *)[collectionView cellForItemAtIndexPath:indexPath];

        if ([self.tool monthOfDate:cell.date] != self.selectedMonth) {
            [self monthScrollToDate:cell.date animated:YES];
            self.date = cell.date;
            
        } else {
            self.date = cell.date;
            [self monthToWeek:nil];
        }
        
    } else if (collectionView == self.weekCollectionView) {
        SRMWeekDayCell *cell = (SRMWeekDayCell *)[collectionView cellForItemAtIndexPath:indexPath];
        self.date = cell.date;

    }
}

// 取消选中操作
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (collectionView == self.monthCollectionView) {
//        UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//        cell.backgroundColor = [UIColor whiteColor];
//    }
}


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


@end
