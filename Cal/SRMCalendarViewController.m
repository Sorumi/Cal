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
#import "SRMMonthBoardView.h"

#import "SRMDayHeader.h"
#import "SRMListHeader.h"
#import "SRMEventStore.h"
#import "SRMEventCell.h"
#import "SRMTask.h"
#import "SRMTaskStore.h"
#import "SRMTaskCell.h"
#import "SRMDayScheduleCell.h"
#import "SRMEventEditViewController.h"

#import "SRMStampStore.h"
#import "SRMStampCell.h"

@interface SRMCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, SRMEventStoreDelegate, SRMDayHeaderDelegate>

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@property (nonatomic) CGFloat const viewWidth;

//@property (nonatomic, strong) SRMCalendarTool *tool;

@property (nonatomic, strong) NSDate *today;
@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic) NSInteger selectedDay;

#pragma mark - Calendar

@property (nonatomic) SRMCalendarViewMode viewMode;

@property (weak, nonatomic) IBOutlet SRMCalendarHeader *headerView;
@property (weak, nonatomic) IBOutlet SRMWeekWeekdayHeader *weekWeekdayHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *weekCollectionView;

#pragma mark - Item

@property (weak, nonatomic) IBOutlet UITableView *monthItemTableView;
@property (nonatomic) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet SRMDayHeader *dayHeader;
@property (weak, nonatomic) IBOutlet UIScrollView *dayScrollView;
@property (weak, nonatomic) IBOutlet UITableView *dayItemTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *dayItemCollectionView;

#pragma mark - AppearanceSetting


@property (weak, nonatomic) IBOutlet UICollectionView *appearanceCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *appearancePageControl;


#pragma mark - Constraint

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthWeekdayViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weekViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weekHeaderTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayScrollViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthItemTableTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appearanceSettingViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appearanceSettingViewBottom;


@end

@implementation SRMCalendarViewController

static NSString * const reuseMonthCellIdentifier = @"MonthDateCell";
static NSString * const reuseWeekCellIdentifier = @"WeekDateCell";
static NSString * const reuseMonthBoardIdentifier = @"MonthBoard";
static NSString * const reuseEventCellIdentifier = @"EventCell";
static NSString * const reuseTaskCellIdentifier = @"TaskCell";
static NSString * const reuseDayScheduleCellIdentifier = @"DayScheduleCell";
static NSString * const reuseStampCellIdentifier = @"StampCell";

#pragma mark - Properties

- (void)setDate:(NSDate *)date
{
    _date = date;
    _selectedYear = [[SRMCalendarTool tool] yearOfDate:_date];
    _selectedMonth = [[SRMCalendarTool tool] monthOfDate:_date];
    _selectedDay = [[SRMCalendarTool tool] dayOfDate:_date];
    [self.headerView setWeekHeaderYear:self.selectedYear month:self.selectedMonth day:self.selectedDay weekday:[[SRMCalendarTool tool] weekdayOfDate:self.date]];
    
    if (self.viewMode == SRMCalendarMonthViewMode) {
        [self weekScrollToDate:self.date animated:NO];
        [self.weekWeekdayHeader setCirclePos:[[SRMCalendarTool tool] weekdayOfDate:self.date] animated:NO];
        
    } else if (self.viewMode == SRMCalendarWeekViewMode) {
        [self monthScrollToDate:self.date animated:NO];
        [self.weekWeekdayHeader setCirclePos:[[SRMCalendarTool tool] weekdayOfDate:self.date] animated:YES];
    }
    [[SRMEventStore sharedStore] fetchDayEvents:date];

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
    _date = [[SRMCalendarTool tool] dateByIgnoringTimeComponentsOfDate:[NSDate date]];
    _today = self.date;
    _selectedYear = [[SRMCalendarTool tool] yearOfDate:_date];
    _selectedMonth = [[SRMCalendarTool tool] monthOfDate:_date];
    _selectedDay = [[SRMCalendarTool tool] dayOfDate:_date];
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
    [self.monthCollectionView registerClass:[SRMMonthBoardView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseMonthBoardIdentifier];
    
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;
    
    self.weekCollectionView.delegate = self;
    self.weekCollectionView.dataSource = self;
    
    self.viewMode = SRMCalendarMonthViewMode;
    
    // month table
    [self.monthItemTableView registerNib:[UINib nibWithNibName:@"SRMEventCell" bundle:nil] forCellReuseIdentifier:reuseEventCellIdentifier];
    [self.monthItemTableView registerNib:[UINib nibWithNibName:@"SRMTaskCell" bundle:nil] forCellReuseIdentifier:reuseTaskCellIdentifier];
    
    self.monthItemTableView.scrollEnabled = NO;
    
    self.monthItemTableView.delegate = self;
    self.monthItemTableView.dataSource = self;
    
    // day scroll
    self.dayScrollView.delegate = self;
    
    // day table
    [self.dayItemTableView registerNib:[UINib nibWithNibName:@"SRMEventCell" bundle:nil] forCellReuseIdentifier:reuseEventCellIdentifier];
    [self.dayItemTableView registerNib:[UINib nibWithNibName:@"SRMTaskCell" bundle:nil] forCellReuseIdentifier:reuseTaskCellIdentifier];
    
    self.dayHeader.delegate = self;
    self.dayItemTableView.delegate = self;
    self.dayItemTableView.dataSource = self;
    
    // day collection
    [self.dayItemCollectionView registerNib:[UINib nibWithNibName:@"SRMDayScheduleCell" bundle:nil] forCellWithReuseIdentifier:reuseDayScheduleCellIdentifier];
    
    self.dayItemCollectionView.delegate = self;
    self.dayItemCollectionView.dataSource = self;

    // appearance collection
    [self.appearanceCollectionView registerNib:[UINib nibWithNibName:@"SRMStampCell" bundle:nil] forCellWithReuseIdentifier:reuseStampCellIdentifier];
    
    self.appearanceCollectionView.delegate = self;
    self.appearanceCollectionView.dataSource = self;
    
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

    // event
    [SRMEventStore sharedStore].delegate = self;
    [[SRMEventStore sharedStore] checkCalendarAuthorizationStatus];
    [[SRMEventStore sharedStore] fetchRecentEvents:self.today];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreDidChanged)
                                                 name:EKEventStoreChangedNotification object:nil];
    
    // appearance setting


}

- (void)viewDidLayoutSubviews
{
    if (self.isFirstTimeViewDidLayoutSubviews) {
        
        [self monthScrollToDate:self.today animated:NO];
        [self weekScrollToDate:self.today animated:NO];
        [self.headerView setMonthHeaderYear:self.selectedYear month:self.selectedMonth];
        
        self.date = self.today;
        self.isFirstTimeViewDidLayoutSubviews = NO;

        // constraint
        self.dayScrollViewHeight.constant = - SRMHeaderHeight - SRMDayHeaderHeight - SRMToolbarHeight - self.viewWidth/7;
        self.appearanceSettingViewHeight.constant = self.view.frame.size.height - SRMHeaderHeight - SRMToolbarHeight - SRMMonthViewWeekdayHeight -self.viewWidth/7*6;
        self.appearanceSettingViewBottom.constant = self.appearanceSettingViewHeight.constant;
    }
}

#pragma mark - Event

- (void)eventStoreDidChanged
{
    [[SRMEventStore sharedStore] fetchRecentEvents:self.today];
    [[SRMEventStore sharedStore] fetchDayEvents:self.today];
}
- (EKEvent *)eventForRow:(NSInteger)row
{
    NSArray *items = [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date];
    return items[row];
}

#pragma mark - <SRMEventStoreDelegate>

- (void)didFetchRecentEvent
{
    [self.monthItemTableView reloadData];
}

- (void)didFetchDayEvent
{
    [self.dayItemTableView reloadData];
    [self.dayItemCollectionView reloadData];

}

#pragma mark - Private

- (void)monthScrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        NSInteger monthCount = [tool monthsFromDate:tool.minimumDate toDate:date];
        CGFloat offsetX = self.viewWidth * monthCount;
        [self.monthCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
        
    }
}

- (void)weekScrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
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
    NSDate *date = [[SRMCalendarTool tool] dateByAddingMonths:-1 toDate:self.date];
    [self monthScrollToDate:date animated:YES];
}

- (IBAction)setNextMonth:(id)sender
{
    NSDate *date = [[SRMCalendarTool tool] dateByAddingMonths:1 toDate:self.date];
    [self monthScrollToDate:date animated:YES];
}

- (IBAction)backToToday:(id)sender
{
    self.date = self.today;
    if (self.viewMode == SRMCalendarMonthViewMode || self.viewMode == SRMCalendarEditViewMode) {
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
    self.monthItemTableTop.constant = self.view.frame.size.height - SRMHeaderHeight-self.viewWidth / 7;
    
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
    self.monthItemTableTop.constant = 0;
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

- (IBAction)showBoard:(id)sender
{
    if (self.viewMode != SRMCalendarEditViewMode) {
        [self backToMode:nil];
        self.viewMode = SRMCalendarEditViewMode;
        [self toggleAppearanceSettingView:YES];
    } else {
        self.viewMode = SRMCalendarMonthViewMode;
        [self toggleAppearanceSettingView:NO];
    }
   
    
//    NSInteger page = round(self.monthCollectionView.contentOffset.x / self.viewWidth);
//    SRMMonthBoardView *board = (SRMMonthBoardView *)[self.monthCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:page]];
//    [board setEditMode];
}

- (void)toggleAppearanceSettingView:(BOOL)show
{
    if (show) {
        self.appearanceSettingViewBottom.constant = 0;
    } else {
        self.appearanceSettingViewBottom.constant = self.appearanceSettingViewHeight.constant;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"EditEvent"]) {
        UINavigationController *nc = segue.destinationViewController;
        SRMEventEditViewController *vc = [nc.viewControllers firstObject];
        
        __weak SRMCalendarViewController *weakSelf = self;
        
        vc.didDismiss = ^{
            [weakSelf.monthItemTableView reloadData];
        };
    }
}

#pragma mark - <SRMDayHeaderDelegate>

- (void)dayHeaderBeginChange:(NSInteger)num
{
    [self.dayScrollView setContentOffset:CGPointMake(self.viewWidth*num, 0) animated:YES];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.monthItemTableView) {
        if (self.lastContentOffset == scrollView.contentOffset.y && scrollView.contentOffset.y == 0) {
            [self downMonthItemTable];
        }
        self.lastContentOffset = scrollView.contentOffset.y;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.dayScrollView) {
        
        NSInteger page = round(scrollView.contentOffset.x / self.viewWidth);
        [self.dayHeader setBorderViewPos:page animated:YES];
    }
    //month view change the label
    if (scrollView == self.monthCollectionView) {
        NSDate *date;
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = round(self.monthCollectionView.contentOffset.x / self.viewWidth);
    
        date = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSInteger year = [tool yearOfDate:date];
        NSInteger month = [tool monthOfDate:date];

        [self.headerView setMonthHeaderYear:year month:month];
        
    }

}

// use finger ti scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if (scrollView == self.monthCollectionView) {

        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = self.monthCollectionView.contentOffset.x / self.viewWidth;
        NSDate *currentBeginningDate = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSDate *selfBeginningDate = [tool beginningOfMonthOfDate:self.date];

        if (![tool date:currentBeginningDate isEqualToDate:selfBeginningDate]) {
            self.date = currentBeginningDate;

        }
        
    } else if (scrollView == self.weekCollectionView) {
        
        SRMCalendarTool *tool = [SRMCalendarTool tool];
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
    if (scrollView == self.monthCollectionView) {

        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = self.monthCollectionView.contentOffset.x / self.viewWidth;
        NSDate *currentBeginningDate = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSDate *selfBeginningDate = [tool beginningOfMonthOfDate:self.date];
        
        if (![tool date:currentBeginningDate isEqualToDate:selfBeginningDate]) {
            self.date = currentBeginningDate;
        }
        
    }
}

#pragma mark - <UITableViewDateSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.monthItemTableView) {
        if (section == 0) {
            return [[SRMTaskStore sharedStore] allTasks].count;
        
        } else if (section == 1) {
            return [[SRMEventStore sharedStore] recentEvents].count;
        }
    } else if (tableView == self.dayItemTableView) {
        if (section == 0) {
//            return [[SRMTaskStore sharedStore] ].count;
            
        } else if (section == 1) {
            return [[SRMEventStore sharedStore] dayEvents:self.date].count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.monthItemTableView) {
        if (indexPath.section == 0) {
            SRMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTaskCellIdentifier forIndexPath:indexPath];
            NSArray *items = [[SRMTaskStore sharedStore] allTasks];
            SRMTask *item = items[indexPath.row];
            
            [cell setTask:item];
            
            return cell;
            
        } else if (indexPath.section == 1) {
            SRMEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseEventCellIdentifier forIndexPath:indexPath];
            NSArray *items = [[SRMEventStore sharedStore] recentEvents];
            EKEvent *item = items[indexPath.row];
            
            [cell setEvent:item];
            
            return cell;
        }
        
    } else if (tableView == self.dayItemTableView) {
        if (indexPath.section == 0) {
            SRMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTaskCellIdentifier forIndexPath:indexPath];
            return cell;
            
        } else if (indexPath.section == 1) {
            SRMEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseEventCellIdentifier forIndexPath:indexPath];
            NSArray *items = [[SRMEventStore sharedStore] dayEvents:self.date];
            EKEvent *item = items[indexPath.row];
            
            [cell setEvent:item];
            
            return cell;
        }
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

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 10;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    if (tableView == self.monthItemTableView) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SRMListHeader" owner:self options:nil];
        SRMListHeader *header = [array firstObject];
        if (section == 0) {
            header.sectionTitleLable.text = @"Tasks";
        } else if (section == 1) {
            header.sectionTitleLable.text = @"Events";
        }
        return header;
//    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    if (collectionView == self.monthCollectionView) {
        return [tool monthsFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
        
    } else if (collectionView == self.weekCollectionView) {
        return [tool weeksFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
        
    } else if (collectionView == self.dayItemCollectionView) {
        return 1;
        
    } else if (collectionView == self.appearanceCollectionView) {
        return 1;
    }
    
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.monthCollectionView) {
        
        return 42;
        
    } else if (collectionView == self.weekCollectionView) {
        
        return 7;
        
    } else if (collectionView == self.dayItemCollectionView) {
        
        return [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date].count;
        
    } else if (collectionView == self.appearanceCollectionView) {
        return [[SRMStampStore sharedStore] allStampsPath].count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.monthCollectionView) {
        SRMMonthDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseMonthCellIdentifier forIndexPath:indexPath];
        
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        
        NSDate *date = [tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate];
        
        NSInteger blankDayCount = [tool weekdayOfDate:[tool beginningOfMonthOfDate:date]];
        NSInteger currentMonthDayCount = [tool dayCountOfMonthofDate:date];
        
        
        NSDate *prevDate = [tool dateByAddingMonths:-1 toDate:date];
        NSInteger previousMonthDayCount = [tool dayCountOfMonthofDate:prevDate];

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
        
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSDate *date = [tool dateByAddingWeeks:indexPath.section toDate:tool.minimumDate];
        date = [tool beginningOfWeekOfDate:date];
        date = [tool dateByAddingDays:indexPath.row toDate:date];
        
        cell.date = date;
        [cell setWeekDate:[tool dayOfDate:date]];
        
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];

        return cell;
    } else if (collectionView == self.dayItemCollectionView) {
        SRMDayScheduleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseDayScheduleCellIdentifier forIndexPath:indexPath];
        NSArray *items = [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date];
        EKEvent *item = items[indexPath.row];
        
        [cell setEvent:item];
        
        return cell;
        
    } else if (collectionView == self.appearanceCollectionView) {
        SRMStampCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseStampCellIdentifier forIndexPath:indexPath];
        [cell setStamp:indexPath.row];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.monthCollectionView || collectionView == self.weekCollectionView) {
        CGFloat cellWidth = self.viewWidth / 7.0;
        CGSize size = CGSizeMake(cellWidth, cellWidth);
        return size;
        
    } else if (collectionView == self.appearanceCollectionView) {
        CGFloat cellWidth = self.viewWidth / 7.0;
        CGFloat cellHeight = collectionView.frame.size.height / 3.0;
        return CGSizeMake(cellWidth, cellHeight);
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.monthCollectionView) {
        if (kind == UICollectionElementKindSectionHeader) {
            SRMMonthBoardView *board = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseMonthBoardIdentifier forIndexPath:indexPath];
            board.userInteractionEnabled = NO;

            SRMCalendarTool *tool = [SRMCalendarTool tool];
            NSDate *date = [tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate];
            [board setStampsForYear:[tool yearOfDate:date] month:[tool monthOfDate:date]];
            return board;
        }
    }
    return nil;
}

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
    if (collectionView == self.monthCollectionView) {
        SRMMonthDayCell *cell = (SRMMonthDayCell *)[collectionView cellForItemAtIndexPath:indexPath];

        if ([[SRMCalendarTool tool] monthOfDate:cell.date] != self.selectedMonth) {
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
