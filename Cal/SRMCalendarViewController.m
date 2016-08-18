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
#import "SRMEventDetailViewController.h"

#import "SRMStampStore.h"
#import "SRMStampCell.h"
#import "SRMStamp.h"
#import "SRMBoardStampCell.h"
#import "SRMAppearanceViewLayout.h"

@interface SRMCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, SRMEventStoreDelegate, SRMDayHeaderDelegate, SRMAppearanceViewLayoutDelegate>

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@property (nonatomic) CGFloat const viewWidth;

@property (nonatomic, strong) NSDate *today;
@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic) NSInteger selectedDay;

#pragma mark - Calendar

@property (nonatomic) SRMCalendarViewMode viewMode;
@property (nonatomic) NSInteger monthPage;

@property (weak, nonatomic) IBOutlet SRMCalendarHeader *headerView;
@property (weak, nonatomic) IBOutlet SRMWeekWeekdayHeader *weekWeekdayHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *weekCollectionView;

#pragma mark - Item

@property (weak, nonatomic) IBOutlet UITableView *monthItemTableView;
@property (nonatomic, strong) UIPanGestureRecognizer *panMonthItem;
@property (nonatomic) BOOL isPanMonthItemUp;

@property (weak, nonatomic) IBOutlet SRMDayHeader *dayHeader;
@property (weak, nonatomic) IBOutlet UIScrollView *dayScrollView;
@property (weak, nonatomic) IBOutlet UITableView *dayItemTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *dayItemCollectionView;

#pragma mark - AppearanceSetting

@property (weak, nonatomic) IBOutlet UICollectionView *appearanceCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *appearancePageControl;

@property (nonatomic, strong) UIImageView *tmpStamp;
@property (nonatomic, strong) NSString *tmpStampName;

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
static NSString * const reuseBoardStampCellIdentifier = @"BoardStampCell";

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
    [self.monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthBoardView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseMonthBoardIdentifier];
    
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
    
    CALayer *layer = self.monthItemTableView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
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
    SRMAppearanceViewLayout *layout = (SRMAppearanceViewLayout *)self.appearanceCollectionView.collectionViewLayout;
    layout.delegate = self;
    
    // add custum gesture
    UIPanGestureRecognizer *panMonthCalender = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMonthCalender:)];
    panMonthCalender.delegate = self;
    [self.monthCollectionView addGestureRecognizer:panMonthCalender];

    UIPanGestureRecognizer *panWeekCalender = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWeekCalender:)];
    panWeekCalender.delegate = self;
    [self.weekCollectionView addGestureRecognizer:panWeekCalender];
    
    _panMonthItem = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMonthItem:)];
    _panMonthItem.delegate = self;
    [self.monthItemTableView addGestureRecognizer:_panMonthItem];
    
   
    UIPanGestureRecognizer *panStamp = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(addStamp:)];
    panStamp.delegate = self;
    [self.appearanceCollectionView addGestureRecognizer:panStamp];
    
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
        
        self.monthPage = self.monthCollectionView.contentOffset.x / self.viewWidth;
        
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
- (EKEvent *)dayEventForRow:(NSInteger)row
{
    NSArray *items = [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date];
    return items[row];
}

#pragma mark - <SRMEventStoreDelegate>

- (void)didFetchRecentEvent
{
    [self.monthItemTableView reloadData];
    if (_viewMode == SRMCalendarItemViewMode) {
        if (self.monthItemTableView.contentSize.height < self.monthItemTableView.frame.size.height) {
            [self.monthItemTableView addGestureRecognizer:self.panMonthItem];
        } else {
            [self.monthItemTableView removeGestureRecognizer:self.panMonthItem];
        }
    }
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

- (void)panMonthCalender:(UIPanGestureRecognizer *)gesture
{
    if (_viewMode != SRMCalendarMonthViewMode) {
        return;
    }
    CGFloat maxHeight = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight + _viewWidth / 7;
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
    
        CGPoint point = [gesture translationInView:self.view];
        
        CGFloat top = _monthWeekdayViewTop.constant + point.y;
        if (top <= 0 && top >= maxHeight ) {
            
            _monthWeekdayViewTop.constant = top;
            _weekViewBottom.constant += point.y / maxHeight * _weekCollectionView.frame.size.height;
            _monthItemTableTop.constant += point.y / maxHeight * (self.view.frame.size.height - SRMHeaderHeight-self.viewWidth / 7);
        }
        [self.view layoutIfNeeded];
        
        [gesture setTranslation:CGPointZero inView:self.view];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self monthToWeek];
    }
}

- (void)panWeekCalender:(UIPanGestureRecognizer *)gesture
{
    if (_viewMode != SRMCalendarWeekViewMode) {
        return;
    }
    CGFloat maxHeight = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight + _viewWidth / 7;
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [gesture translationInView:self.view];
        
        CGFloat top = _monthWeekdayViewTop.constant + point.y;
        if (top <= 0 && top >= maxHeight ) {
            
            _monthWeekdayViewTop.constant = top;
            _weekViewBottom.constant += point.y / maxHeight * _weekCollectionView.frame.size.height;
            _monthItemTableTop.constant += point.y / maxHeight * (self.view.frame.size.height - SRMHeaderHeight-self.viewWidth / 7);
        }
        [self.view layoutIfNeeded];
        
        [gesture setTranslation:CGPointZero inView:self.view];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self weekToMonth];
    }
}

- (void)panMonthItem:(UIPanGestureRecognizer *)gesture
{
    CGFloat maxHeight = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight;
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [gesture translationInView:_monthItemTableView];
        _isPanMonthItemUp = point.y <= 0 ? YES : NO;
        
        CGFloat top = _monthWeekdayViewTop.constant + point.y;
        
         if (top <= 0 && top >= maxHeight ) {
             _monthWeekdayViewTop.constant = top;
         }
        [self.view layoutIfNeeded];
        
        [gesture setTranslation:CGPointZero inView:self.view];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (_isPanMonthItemUp) {
            [self upMonthItemTable];
        } else {
            [self downMonthItemTable];
        }
        
    }
}

- (void)monthToWeek
{
//    if (self.viewMode != SRMCalendarMonthViewMode) {
//        return;
//    }
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

- (void)weekToMonth
{
//    if (self.viewMode != SRMCalendarWeekViewMode) {
//        return;
//    }
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

- (void)upMonthItemTable
{
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
                             if (self.monthItemTableView.contentSize.height < self.monthItemTableView.frame.size.height) {
                                 [self.monthItemTableView addGestureRecognizer:self.panMonthItem];
                             } else {
                                 [self.monthItemTableView removeGestureRecognizer:self.panMonthItem];
                             }
                         }
                     }];
}

- (void)downMonthItemTable
{
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
                             [self.monthItemTableView addGestureRecognizer:self.panMonthItem];
                         }
                     }];
}

- (IBAction)backToMode:(id)sender
{
    if (self.viewMode == SRMCalendarWeekViewMode) {
        [self weekToMonth];
        
    } else if (self.viewMode == SRMCalendarItemViewMode) {
        [self downMonthItemTable];
    }
}

- (IBAction)showBoard:(id)sender
{
    if (self.viewMode != SRMCalendarEditViewMode) {
        [self backToMode:nil];
        self.viewMode = SRMCalendarEditViewMode;
        self.monthCollectionView.scrollEnabled = NO;
        [self toggleAppearanceSettingView:YES];
        [self.monthCollectionView reloadData];
        
    } else {
        self.viewMode = SRMCalendarMonthViewMode;
        self.monthCollectionView.scrollEnabled = YES;
        [self toggleAppearanceSettingView:NO];
        [self.monthCollectionView reloadData];
    }
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

- (void)addStamp:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [gesture locationInView:self.appearanceCollectionView];
        NSIndexPath *indexPath = [self.appearanceCollectionView indexPathForItemAtPoint:point];
        if (!indexPath) {
            return;
        }
        NSInteger num = indexPath.row;
        _tmpStamp = [[UIImageView alloc] initWithImage:[[SRMStampStore sharedStore] stampForNum:num]];
        CGRect bounds = _tmpStamp.bounds;
        bounds.size.width /= 2;
        bounds.size.height /= 2;
        _tmpStamp.bounds = bounds;
        CGPoint center = [gesture locationInView:self.view];
        center.y -= 40;
        _tmpStamp.center = center;
        _tmpStampName = [SRMStampStore sharedStore].allStampsPath[num];
        [self.view addSubview:_tmpStamp];
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        if (!_tmpStamp) {
            return;
        }
        CGPoint point = [gesture translationInView:self.view];

        CGFloat x = _tmpStamp.center.x + point.x;
        CGFloat y = _tmpStamp.center.y + point.y;
        
        _tmpStamp.center = CGPointMake(x, y);
                [gesture setTranslation:CGPointZero inView:self.view];

    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!_tmpStamp) {
            return;
        }
        if (CGRectContainsPoint(self.monthCollectionView.frame, _tmpStamp.center)) {
            
            SRMMonthBoardView *board = (SRMMonthBoardView *)[self.monthCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.monthPage]];

            CGPoint center = [board convertPoint:_tmpStamp.center fromView:self.view];

            SRMStamp *stamp = [[SRMStamp alloc] initWithName:_tmpStampName xProp:center.x/self.viewWidth yProp:center.y/(self.viewWidth/7*6) xScale:0.5 yScale:0.5] ;
            [[SRMStampStore sharedStore] addStamp:stamp forYear:_selectedYear month:_selectedMonth];

            [board.boardCollectionView reloadData];

        }
        [_tmpStamp removeFromSuperview];
        _tmpStamp = nil;
    }
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

#pragma mark - <SRMAppearanceViewLayoutDelegate>

- (void)didPrepareLayout:(SRMAppearanceViewLayout *)layout
{
    self.appearancePageControl.numberOfPages = layout.page;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    return fabs(velocity.y) > fabs(velocity.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (otherGestureRecognizer == self.appearanceCollectionView.panGestureRecognizer) {
        return YES;
    }
    
    return NO;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.monthItemTableView) {
        if (scrollView.contentOffset.y == 0) {
            [_monthItemTableView addGestureRecognizer:_panMonthItem];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.dayScrollView) {
        
        NSInteger page = round(scrollView.contentOffset.x / self.viewWidth);
        [self.dayHeader setBorderViewPos:page animated:YES];
        
    } else if (scrollView == self.monthCollectionView) {
        NSDate *date;
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = round(self.monthCollectionView.contentOffset.x / self.viewWidth);
    
        date = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSInteger year = [tool yearOfDate:date];
        NSInteger month = [tool monthOfDate:date];

        [self.headerView setMonthHeaderYear:year month:month];
    
    } else if (scrollView == self.appearanceCollectionView) {
        NSInteger page = round(scrollView.contentOffset.x / scrollView.frame.size.width);
        self.appearancePageControl.currentPage = page;
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
        self.monthPage = page;
        
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
        self.monthPage = page;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.monthItemTableView && indexPath.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailNavigation"];
        SRMEventDetailViewController *vc = nvc.viewControllers[0];
        NSArray *items = [[SRMEventStore sharedStore] recentEvents];
        vc.event = items[indexPath.row];
        
        [self presentViewController:nvc animated:YES completion:nil];
    }
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
        
//        if ([tool date:date isEqualToDate:_today]) {
//            [cell setToday:YES];
//        } else {
//            [cell setToday:NO];
//        }
        
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
    if (collectionView == self.weekCollectionView) {
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

            SRMCalendarTool *tool = [SRMCalendarTool tool];
            NSDate *date = [tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate];
            
            [board setYear:[tool yearOfDate:date] month:[tool monthOfDate:date]];
            [board setEditMode:self.viewMode == SRMCalendarEditViewMode ? YES : NO];
            [board.boardCollectionView reloadData];
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
            [self monthToWeek];
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
