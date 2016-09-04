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
#import "SRMCalendarToolbar.h"
#import "SRMMonthDayCell.h"
#import "SRMWeekDayCell.h"
#import "SRMMonthWeekdayHeader.h"
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
#import "SRMThemeStore.h"
#import "SRMAppearanceCell.h"
#import "SRMStamp.h"
#import "SRMBoardStampCell.h"
#import "SRMAppearanceViewLayout.h"

@interface SRMCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, SRMEventStoreDelegate, SRMDayHeaderDelegate, SRMAppearanceViewLayoutDelegate>

@property (nonatomic) BOOL isFirstTimeViewDidLayoutSubviews;

@property (nonatomic) CGFloat const viewWidth;
@property (nonatomic) CGFloat const monthViewHeight;
@property (nonatomic) CGFloat const weekViewHeight;

@property (nonatomic, strong) NSDate *today;
@property (nonatomic) NSInteger selectedYear;
@property (nonatomic) NSInteger selectedMonth;
@property (nonatomic) NSInteger selectedDay;

#pragma mark - Calendar

@property (nonatomic) SRMCalendarViewMode viewMode;
@property (nonatomic) SRMAppearanceEditMode appearanceMode;

@property (nonatomic) NSInteger monthPage;

@property (weak, nonatomic) IBOutlet SRMCalendarFrontHeader *headerFrontView;
@property (weak, nonatomic) IBOutlet SRMCalendarBackHeader *headerBackView;
@property (weak, nonatomic) IBOutlet SRMCalendarToolbar *toolbar;


@property (weak, nonatomic) IBOutlet SRMMonthWeekdayHeader *monthWeekdayHeader;
@property (weak, nonatomic) IBOutlet SRMWeekWeekdayHeader *weekWeekdayHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *monthCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *weekCollectionView;
@property (nonatomic) BOOL isPanMonthCalendarUp;

#pragma mark - Item

@property (weak, nonatomic) IBOutlet UITableView *monthItemTableView;
@property (nonatomic, strong) UIPanGestureRecognizer *panMonthItem;
@property (nonatomic) BOOL isPanMonthItemUp;

@property (weak, nonatomic) IBOutlet SRMDayHeader *dayHeader;
@property (weak, nonatomic) IBOutlet UIScrollView *dayScrollView;
@property (weak, nonatomic) IBOutlet UITableView *dayItemTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *dayItemCollectionView;

#pragma mark - AppearanceSetting

//@property (weak, nonatomic) IBOutlet UIStackView *appearanceToolbar;

@property (weak, nonatomic) IBOutlet UICollectionView *appearanceCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *appearancePageControl;

@property (nonatomic, strong) UIPanGestureRecognizer *panStamp;
@property (nonatomic, strong) UIImageView *tmpStamp;
@property (nonatomic, strong) NSString *tmpStampName;

#pragma mark - Constraint

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerFrontTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerBackHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthWeekdayViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weekViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weekHeaderTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backButtonLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayScrollViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *monthItemTableTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appearanceSettingViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appearanceSettingViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *appearanceToolbarLeading;

@end

@implementation SRMCalendarViewController

static NSString * const reuseMonthCellIdentifier = @"MonthDateCell";
static NSString * const reuseWeekCellIdentifier = @"WeekDateCell";
static NSString * const reuseMonthBoardIdentifier = @"MonthBoard";
static NSString * const reuseEventCellIdentifier = @"EventCell";
static NSString * const reuseTaskCellIdentifier = @"TaskCell";
static NSString * const reuseDayScheduleCellIdentifier = @"DayScheduleCell";
static NSString * const reuseAppearanceCellIdentifier = @"AppearanceCell";
static NSString * const reuseBoardStampCellIdentifier = @"BoardStampCell";

#pragma mark - Properties

- (void)setDate:(NSDate *)date
{
    _date = date;
    _selectedYear = [[SRMCalendarTool tool] yearOfDate:_date];
    _selectedMonth = [[SRMCalendarTool tool] monthOfDate:_date];
    _selectedDay = [[SRMCalendarTool tool] dayOfDate:_date];
    [_headerFrontView setMonthHeaderYear:_selectedYear month:_selectedMonth];
    [_headerFrontView setWeekHeaderYear:_selectedYear month:_selectedMonth day:_selectedDay weekday:[[SRMCalendarTool tool] weekdayOfDate:_date]];
    
    if (_viewMode == SRMCalendarMonthViewMode || _viewMode == SRMCalendarItemViewMode) {
        [self weekScrollToDate:self.date animated:NO];
        [_weekWeekdayHeader setCirclePos:[[SRMCalendarTool tool] weekdayOfDate:_date] animated:NO];
        
    } else if (_viewMode == SRMCalendarWeekViewMode) {
        [self monthScrollToDate:self.date animated:NO];
        [_weekWeekdayHeader setCirclePos:[[SRMCalendarTool tool] weekdayOfDate:_date] animated:YES];
        
    }
    
//    NSLog(@"%@", [[SRMCalendarTool tool] dateAndTimeFormat:date]);
    [[SRMEventStore sharedStore] fetchDayEvents:date];
    [[SRMThemeStore sharedStore] setCurrentThemeYear:_selectedYear month:_selectedMonth];
    [self updateTheme];

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
    self.monthViewHeight = _viewWidth / 7 * 6;
    self.weekViewHeight = _viewWidth / 7;

    // collection
    [_monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthDayCell" bundle:nil] forCellWithReuseIdentifier:reuseMonthCellIdentifier];
    [_weekCollectionView registerNib:[UINib nibWithNibName:@"SRMWeekDayCell" bundle:nil] forCellWithReuseIdentifier:reuseWeekCellIdentifier];
    [_monthCollectionView registerNib:[UINib nibWithNibName:@"SRMMonthBoardView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseMonthBoardIdentifier];
    
    _monthCollectionView.delegate = self;
    _monthCollectionView.dataSource = self;

    _weekCollectionView.delegate = self;
    _weekCollectionView.dataSource = self;
    
    self.viewMode = SRMCalendarMonthViewMode;
    
    // month table
    [_monthItemTableView registerNib:[UINib nibWithNibName:@"SRMEventCell" bundle:nil] forCellReuseIdentifier:reuseEventCellIdentifier];
    [_monthItemTableView registerNib:[UINib nibWithNibName:@"SRMTaskCell" bundle:nil] forCellReuseIdentifier:reuseTaskCellIdentifier];
    
    _monthItemTableView.scrollEnabled = NO;
    
    _monthItemTableView.delegate = self;
    _monthItemTableView.dataSource = self;
    
    CALayer *layer = _monthItemTableView.layer;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 1;
    layer.shadowColor = [UIColor darkGrayColor].CGColor;
    layer.shadowOpacity = 0.3;
    
    // day scroll
    _dayScrollView.delegate = self;
    
    // day table
    [_dayItemTableView registerNib:[UINib nibWithNibName:@"SRMEventCell" bundle:nil] forCellReuseIdentifier:reuseEventCellIdentifier];
    [_dayItemTableView registerNib:[UINib nibWithNibName:@"SRMTaskCell" bundle:nil] forCellReuseIdentifier:reuseTaskCellIdentifier];
    
    _dayHeader.delegate = self;
    _dayItemTableView.delegate = self;
    _dayItemTableView.dataSource = self;
    
    // day collection
    [_dayItemCollectionView registerNib:[UINib nibWithNibName:@"SRMDayScheduleCell" bundle:nil] forCellWithReuseIdentifier:reuseDayScheduleCellIdentifier];
    
    _dayItemCollectionView.delegate = self;
    _dayItemCollectionView.dataSource = self;

    // appearance collection
    [_appearanceCollectionView registerNib:[UINib nibWithNibName:@"SRMAppearanceCell" bundle:nil] forCellWithReuseIdentifier:reuseAppearanceCellIdentifier];
    
    _appearanceCollectionView.delegate = self;
    _appearanceCollectionView.dataSource = self;
    SRMAppearanceViewLayout *layout = (SRMAppearanceViewLayout *)_appearanceCollectionView.collectionViewLayout;
    layout.delegate = self;
    
    // add custum gesture
    UIPanGestureRecognizer *panMonthCalender = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMonthCalender:)];
    panMonthCalender.delegate = self;
    [_monthCollectionView addGestureRecognizer:panMonthCalender];

    UIPanGestureRecognizer *panWeekCalender = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWeekCalender:)];
    panWeekCalender.delegate = self;
    [_weekCollectionView addGestureRecognizer:panWeekCalender];
    
    _panMonthItem = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMonthItem:)];
    _panMonthItem.delegate = self;
    [_monthItemTableView addGestureRecognizer:_panMonthItem];
    
   
    _panStamp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(addStamp:)];
    _panStamp.delegate = self;
    
    _isFirstTimeViewDidLayoutSubviews = YES;

    // event
    [SRMEventStore sharedStore].delegate = self;
    [[SRMEventStore sharedStore] checkCalendarAuthorizationStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreDidChanged)
                                                 name:EKEventStoreChangedNotification object:nil];

}

- (void)viewDidLayoutSubviews
{
    if (_isFirstTimeViewDidLayoutSubviews) {
        
        [self monthScrollToDate:self.today animated:NO];
        [self weekScrollToDate:self.today animated:NO];
        [_headerFrontView setMonthHeaderYear:self.selectedYear month:self.selectedMonth];
        
        _monthPage = _monthCollectionView.contentOffset.x / _viewWidth;
        
        self.date = self.today;
        self.isFirstTimeViewDidLayoutSubviews = NO;

        // constraint
        _dayScrollViewHeight.constant = - SRMHeaderHeight - SRMDayHeaderHeight - SRMToolbarHeight - _weekViewHeight;
        _appearanceSettingViewHeight.constant = self.view.frame.size.height - SRMHeaderHeight - SRMToolbarHeight - SRMMonthViewWeekdayHeight -_monthViewHeight;
        _appearanceSettingViewBottom.constant = self.appearanceSettingViewHeight.constant;
    }
}

#pragma mark - Event

- (void)eventStoreDidChanged
{
//    NSLog(@"event change!");
    [[SRMEventStore sharedStore] fetchDaysEventsInMonth:self.date];
    [[SRMEventStore sharedStore] fetchDayEvents:self.date];
}

- (EKEvent *)dayEventForRow:(NSInteger)row
{
    NSArray *items = [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date];
    return items[row];
}

#pragma mark - <SRMEventStoreDelegate>

- (void)didFetchDayEvent
{
    [_dayItemTableView reloadData];
    [_dayItemCollectionView reloadData];
}

- (void)didFetchDaysEventInMonth
{
//    NSLog(@"didFetchMonth%@", [[SRMCalendarTool tool] dateAndTimeFormat:_date]);
    [_monthItemTableView reloadData];
    [_monthCollectionView reloadData];
}

#pragma mark - Private

- (void)monthScrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        
        //
        [[SRMEventStore sharedStore] fetchDaysEventsInMonth:date];
        
        NSInteger monthCount = [tool monthsFromDate:tool.minimumDate toDate:date];
        CGFloat offsetX = _viewWidth * monthCount;
        [_monthCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
        
    }
}

- (void)weekScrollToDate:(NSDate *)date animated:(BOOL)animated
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    if ([tool monthsFromDate:tool.minimumDate toDate:date] > 0 && [tool monthsFromDate:date toDate:tool.maximumDate] > 0 ) {
        date = [tool beginningOfWeekOfDate:date];
        NSDate *beginDate = [tool beginningOfWeekOfDate:tool.minimumDate];
        NSInteger weekCount = [tool weeksFromDate:beginDate toDate:date];
        CGFloat offsetX = _viewWidth * weekCount;
        [_weekCollectionView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
    }
}

#pragma mark - Action

- (IBAction)setPrevMonth:(id)sender
{
    NSDate *date = [[SRMCalendarTool tool] dateByAddingMonths:-1 toDate:self.date];
    if (self.viewMode == SRMCalendarItemViewMode) {
        [self monthScrollToDate:date animated:NO];
    } else {
        [self monthScrollToDate:date animated:YES];
    }
}

- (IBAction)setNextMonth:(id)sender
{
    NSDate *date = [[SRMCalendarTool tool] dateByAddingMonths:1 toDate:self.date];
    if (self.viewMode == SRMCalendarItemViewMode) {
        [self monthScrollToDate:date animated:NO];
    } else {
        [self monthScrollToDate:date animated:YES];
    }
}

- (IBAction)backToToday:(id)sender
{
    
    if (self.viewMode == SRMCalendarMonthViewMode || self.viewMode == SRMCalendarEditViewMode) {
        [self monthScrollToDate:self.today animated:YES];
        
    } else if (self.viewMode == SRMCalendarItemViewMode) {
        [self monthScrollToDate:self.today animated:NO];
        
    } else if (self.viewMode == SRMCalendarWeekViewMode) {
        [self weekScrollToDate:self.today animated:YES];
    }
}

- (void)panMonthCalender:(UIPanGestureRecognizer *)gesture
{
    if (_viewMode != SRMCalendarMonthViewMode && _viewMode != SRMCalendarHeaderViewMode) {
        return;
    }
    CGFloat minHeight = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight + _weekViewHeight;
    CGFloat maxHeight = self.view.frame.size.height - SRMHeaderHeight - SRMMonthViewWeekdayHeight - _monthViewHeight - SRMToolbarHeight;
    
    if (gesture.state == UIGestureRecognizerStateChanged) {

        CGPoint point = [gesture translationInView:self.view];
        _isPanMonthCalendarUp = point.y <= 0 ? YES : NO;
        
        CGFloat weekdayTop = _monthWeekdayViewTop.constant + point.y;
        CGFloat headerTop = _headerFrontTop.constant + point.y;
        
        if (weekdayTop <= 0 && weekdayTop >= minHeight && _headerFrontTop.constant == 0) {
            
            _monthWeekdayViewTop.constant = weekdayTop;
            _weekViewBottom.constant += point.y / minHeight * _weekCollectionView.frame.size.height;
            _monthItemTableTop.constant += point.y / minHeight * (self.view.frame.size.height - SRMHeaderHeight - _weekViewHeight);
            [self.view layoutIfNeeded];
            
        } else if (headerTop >= 0 && headerTop <= maxHeight && _monthWeekdayViewTop.constant == 0) {
            _headerFrontTop.constant = headerTop;
            _headerBackHeight.constant += point.y / maxHeight * (maxHeight-SRMHeaderHeight);
            _headerFrontView.tintColor = [self fadeFromColor:_headerFrontView.headerTextColorNormal toColor:_headerFrontView.headerTextColorFull withPercentage:headerTop/maxHeight];
            [self.view layoutIfNeeded];
        }
        
        
        [gesture setTranslation:CGPointZero inView:self.view];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_headerFrontTop.constant > 0) {
            if (_isPanMonthCalendarUp) {
                [self fullHeaderToMonth];
            } else {
                [self monthToFullHeader];
            }
            
        } else if (_monthWeekdayViewTop.constant < 0) {
            if (_isPanMonthCalendarUp) {
                [self monthToWeek];
            } else {
                [self weekToMonth];
            }
        }
       
    }
}

- (void)panWeekCalender:(UIPanGestureRecognizer *)gesture
{
    if (_viewMode != SRMCalendarWeekViewMode) {
        return;
    }
    CGFloat maxHeight = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight + _weekViewHeight;
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [gesture translationInView:self.view];
        
        CGFloat top = _monthWeekdayViewTop.constant + point.y;
        if (top <= 0 && top >= maxHeight ) {
            
            _monthWeekdayViewTop.constant = top;
            _weekViewBottom.constant += point.y / maxHeight * _weekCollectionView.frame.size.height;
            _monthItemTableTop.constant += point.y / maxHeight * (self.view.frame.size.height - SRMHeaderHeight - _weekViewHeight);
            [self.view layoutIfNeeded];
        }
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
             [self.view layoutIfNeeded];
         }
        [gesture setTranslation:CGPointZero inView:self.view];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (_isPanMonthItemUp) {
            [self upMonthItemTable];
        } else {
            [self downMonthItemTable];
        }
        
    }
}

- (void)monthToFullHeader
{
    self.viewMode = SRMCalendarHeaderViewMode;
    _headerFrontView.isFull = YES;
    
    // animation
    _headerBackHeight.constant = self.view.frame.size.height - SRMHeaderHeight - SRMMonthViewWeekdayHeight - _monthViewHeight - SRMToolbarHeight;
    _headerFrontTop.constant = _headerBackHeight.constant;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _headerFrontView.tintColor = _headerFrontView.headerTextColorFull;
//                         _headerFrontView.alpha = 1;
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

- (void)fullHeaderToMonth
{
    self.viewMode = SRMCalendarMonthViewMode;
    _headerFrontView.isFull = NO;
    
    // animation
    _headerBackHeight.constant = SRMHeaderHeight;
    _headerFrontTop.constant = 0;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _headerFrontView.tintColor = _headerFrontView.headerTextColorNormal;
//                         _headerFrontView.alpha = 1;
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

- (void)monthToWeek
{
    self.viewMode = SRMCalendarWeekViewMode;
    
    // animation
    _headerFrontTop.constant = 0;
    _headerBackHeight.constant = SRMHeaderHeight;
    
    _monthWeekdayViewTop.constant = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight + _weekViewHeight;
    _weekViewBottom.constant = _weekCollectionView.frame.size.height;
    _monthItemTableTop.constant = self.view.frame.size.height - SRMHeaderHeight - _weekViewHeight;
    
    _weekHeaderTrailing.constant = _headerFrontView.weekHeader.frame.size.width;
    _backButtonLeading.constant = -42;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _headerFrontView.monthHeader.alpha = 0;
                         _headerFrontView.weekHeader.alpha = 1;
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

- (void)weekToMonth
{
    self.viewMode = SRMCalendarMonthViewMode;
    
    // animation

    _monthWeekdayViewTop.constant = 0;
    _weekViewBottom.constant = 0;
    _monthItemTableTop.constant = 0;
    _weekHeaderTrailing.constant = 0;
    _backButtonLeading.constant = 0;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _headerFrontView.monthHeader.alpha = 1;
                         _headerFrontView.weekHeader.alpha = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:NULL];
}

- (void)upMonthItemTable
{
    self.viewMode = SRMCalendarItemViewMode;

    // animation
    _monthWeekdayViewTop.constant = - _monthCollectionView.frame.size.height - SRMMonthViewWeekdayHeight;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             _monthItemTableView.scrollEnabled = YES;
                         }
                     }];
}

- (void)downMonthItemTable
{
    self.viewMode = SRMCalendarMonthViewMode;
    
    // animation
    _monthWeekdayViewTop.constant = 0;
    [_monthItemTableView setContentOffset:CGPointZero  animated:YES];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             _monthItemTableView.scrollEnabled = NO;
//                             [_monthItemTableView addGestureRecognizer:self.panMonthItem];
                         }
                     }];
}

- (IBAction)backToMode:(id)sender
{
    if (self.viewMode == SRMCalendarWeekViewMode) {
        [self weekToMonth];
        
    } else if (self.viewMode == SRMCalendarItemViewMode) {
        [self downMonthItemTable];
        
    } else if (self.viewMode == SRMCalendarHeaderViewMode) {
        [self fullHeaderToMonth];
    }
}

- (IBAction)appearanceEdit:(id)sender
{
    if (self.viewMode != SRMCalendarEditViewMode) {
        [self backToMode:nil];
        self.viewMode = SRMCalendarEditViewMode;
        _monthCollectionView.scrollEnabled = NO;
        [self toggleAppearanceSettingView:YES];
        [_monthCollectionView reloadData];
        
        [self setStampMode:nil];
    }
}

- (IBAction)endAppearanceEdit:(id)sender
{
    if (self.viewMode == SRMCalendarEditViewMode) {
        self.viewMode = SRMCalendarMonthViewMode;
        _monthCollectionView.scrollEnabled = YES;
        [self toggleAppearanceSettingView:NO];
        [_monthCollectionView reloadData];
    }
}

- (void)toggleAppearanceSettingView:(BOOL)show
{
    if (show) {
        _appearanceSettingViewBottom.constant = 0;
        _appearanceToolbarLeading.constant = 0;
    } else {
        _appearanceSettingViewBottom.constant = self.appearanceSettingViewHeight.constant;
        _appearanceToolbarLeading.constant = 100;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         _toolbar.mainToolbar.alpha = show ? 0 : 1;
                         _toolbar.appearanceToolbar.alpha = show ? 1 : 0;
                         [self.view layoutIfNeeded];
                     }];
}

- (IBAction)setStampMode:(id)sender
{
    self.appearanceMode = SRMAppearanceEditStampMode;
    [_appearanceCollectionView addGestureRecognizer:_panStamp];
    [_appearanceCollectionView reloadData];
}

- (IBAction)setThemeMode:(id)sender
{
    self.appearanceMode = SRMAppearanceEditThemeMode;
    [_appearanceCollectionView removeGestureRecognizer:_panStamp];
    [_appearanceCollectionView reloadData];
}

- (void)addStamp:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [gesture locationInView:_appearanceCollectionView];
        NSIndexPath *indexPath = [_appearanceCollectionView indexPathForItemAtPoint:point];
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
        if (CGRectContainsPoint(_monthCollectionView.frame, _tmpStamp.center)) {
            
            SRMMonthBoardView *board = (SRMMonthBoardView *)[_monthCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.monthPage]];

            CGPoint center = [board convertPoint:_tmpStamp.center fromView:self.view];

            SRMStamp *stamp = [[SRMStamp alloc] initWithName:_tmpStampName xProp:center.x/_viewWidth yProp:center.y/_monthViewHeight xScale:0.5 yScale:0.5] ;
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
//    if ([segue.identifier isEqual: @"EditEvent"]) {
//        UINavigationController *nc = segue.destinationViewController;
//        SRMEventEditViewController *vc = [nc.viewControllers firstObject];
//
//        
//
//    }
}

#pragma mark - Theme

- (void)updateTheme
{
    SRMThemeStore *themeStore = [SRMThemeStore sharedStore];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         _headerBackView.backgroundColor = [themeStore colorForName:@"HeaderColor"];
                         _headerFrontView.headerTextColorNormal = [themeStore colorForName:@"HeaderTextColorNormal"];
                         _headerFrontView.headerTextColorFull = [themeStore colorForName:@"HeaderTextColorFull"];
                         
                         _toolbar.backgroundColor = [themeStore colorForName:@"HeaderColor"];
                         _toolbar.toollbarTextColor = [themeStore colorForName:@"ToolbarTextColor"];
                         
                         _monthWeekdayHeader.weekdayTextColor = [themeStore colorForName:@"MonthWeekdayTextColor"];

                         [_headerFrontView updateTheme];
                     }];
    
    _dayHeader.tintColor = [themeStore colorForName:@"HeaderColor"];
    _weekWeekdayHeader.circleColor = [themeStore colorForName:@"WeekCircleColor"];

}

- (void)selectTheme
{
    SRMMonthBoardView *board = (SRMMonthBoardView *)[_monthCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:_monthPage]];
    [board updateThemeAnimate:YES];

    [_monthCollectionView reloadData];
    [self updateTheme];
}

#pragma mark - Color

- (UIColor *)fadeFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor withPercentage:(CGFloat)percentage
{
    // get the RGBA values from the colours
    CGFloat fromRed, fromGreen, fromBlue, fromAlpha;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed, toGreen, toBlue, toAlpha;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    //calculate the actual RGBA values of the fade colour
    CGFloat red = (toRed - fromRed) * percentage + fromRed;
    CGFloat green = (toGreen - fromGreen) * percentage + fromGreen;
    CGFloat blue = (toBlue - fromBlue) * percentage + fromBlue;
    CGFloat alpha = (toAlpha - fromAlpha) * percentage + fromAlpha;
    
    // return the fade colour
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - <SRMDayHeaderDelegate>

- (void)dayHeaderBeginChange:(NSInteger)num
{
    [_dayScrollView setContentOffset:CGPointMake(_viewWidth*num, 0) animated:YES];
}

#pragma mark - <SRMAppearanceViewLayoutDelegate>

- (void)didPrepareLayout:(SRMAppearanceViewLayout *)layout
{
    self.appearancePageControl.numberOfPages = layout.page;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer == _panStamp) {
        CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
        return fabs(velocity.y) > fabs(velocity.x);
        
    } else if (panGestureRecognizer == _panMonthItem) {
        CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];

        if (self.viewMode != SRMCalendarItemViewMode) {
            return YES;
        } else {
            return _monthItemTableView.contentOffset.y == 0 && velocity.y > 0;
        }
    } else {
        CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
        return fabs(velocity.y) > fabs(velocity.x);
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (otherGestureRecognizer == _appearanceCollectionView.panGestureRecognizer) {
        return YES;
    }
    return NO;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _dayScrollView) {
        
        NSInteger page = round(scrollView.contentOffset.x / _viewWidth);
        [_dayHeader setBorderViewPos:page animated:YES];
        
    } else if (scrollView == _monthCollectionView) {
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = round(_monthCollectionView.contentOffset.x / _viewWidth);

        // set date
        NSDate *currentBeginningDate = [tool dateByAddingMonths:page toDate:tool.minimumDate];
        NSDate *selfBeginningDate = [tool beginningOfMonthOfDate:self.date];
        
        if (![tool date:currentBeginningDate isEqualToDate:selfBeginningDate]) {
            self.date = currentBeginningDate;
        }

    } else if (scrollView == _appearanceCollectionView) {
        NSInteger page = round(scrollView.contentOffset.x / scrollView.frame.size.width);
        self.appearancePageControl.currentPage = page;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _monthCollectionView) {
        
        NSDate *prevMonth = [[SRMCalendarTool tool] dateByAddingMonths:-1 toDate:_date];
        NSDate *nextMonth = [[SRMCalendarTool tool] dateByAddingMonths:1 toDate:_date];
        [[SRMEventStore sharedStore] fetchDaysEventsInMonth:prevMonth];
        [[SRMEventStore sharedStore] fetchDaysEventsInMonth:nextMonth];
    }
}

// use finger to scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    if (scrollView == _monthCollectionView) {

        NSInteger page = _monthCollectionView.contentOffset.x / _viewWidth;

        self.monthPage = page;
        [_monthItemTableView beginUpdates];
        [_monthItemTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [_monthItemTableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [_monthItemTableView endUpdates];
        
        
//        SRMMonthBoardView *board = (SRMMonthBoardView *)[_monthCollectionView supplementaryViewForElementKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:_monthPage]];
//        [board.boardCollectionView reloadData];
        
    } else if (scrollView == _weekCollectionView) {
        
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = _weekCollectionView.contentOffset.x / _viewWidth;
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
    if (scrollView == _monthCollectionView) {

        NSInteger page = _monthCollectionView.contentOffset.x / _viewWidth;

        self.monthPage = page;
        [_monthItemTableView beginUpdates];
        [_monthItemTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [_monthItemTableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [_monthItemTableView endUpdates];
        
    } else if (scrollView == _weekCollectionView) {
        SRMCalendarTool *tool = [SRMCalendarTool tool];
        NSInteger page = _weekCollectionView.contentOffset.x / _viewWidth;
        NSDate *currentBeginningDate = [tool beginningOfWeekOfDate:tool.minimumDate];
        currentBeginningDate = [tool dateByAddingWeeks:page toDate:currentBeginningDate];
        NSDate *selfBeginningDate = [tool beginningOfWeekOfDate:self.date];
        
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
    if (tableView == _monthItemTableView) {
        if (section == 0) {
//            return [[SRMTaskStore sharedStore] allTasks].count;
        
        } else if (section == 1) {
            return [[SRMEventStore sharedStore] monthEvents:_date].count;
        }
    } else if (tableView == _dayItemTableView) {
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
    if (tableView == _monthItemTableView) {
        if (indexPath.section == 0) {
            SRMTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseTaskCellIdentifier forIndexPath:indexPath];
            NSArray *items = [[SRMTaskStore sharedStore] allTasks];
            SRMTask *item = items[indexPath.row];
            
            [cell setTask:item];
            
            return cell;
            
        } else if (indexPath.section == 1) {
            SRMEventCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseEventCellIdentifier forIndexPath:indexPath];
            NSArray *items = [[SRMEventStore sharedStore] monthEvents:_date];
            
//            NSLog(@"%lu %lu", items.count, indexPath.row);
            EKEvent *item = items[indexPath.row];
            
            [cell setEvent:item];
            
            return cell;
        }
        
    } else if (tableView == _dayItemTableView) {
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
//    if (tableView == _monthItemTableView) {
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
    if (tableView == _monthItemTableView && indexPath.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailNavigation"];
        SRMEventDetailViewController *vc = nvc.viewControllers[0];
        NSArray *items = [[SRMEventStore sharedStore] monthEvents:_date];
        vc.event = items[indexPath.row];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:nvc animated:YES completion:nil];
        });

    } else if (tableView == _dayItemTableView && indexPath.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"DetailNavigation"];
        SRMEventDetailViewController *vc = nvc.viewControllers[0];
        NSArray *items = [[SRMEventStore sharedStore] dayEvents:self.date];
        vc.event = items[indexPath.row];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:nvc animated:YES completion:nil];
        });
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    if (collectionView == _monthCollectionView) {
        return [tool monthsFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
        
    } else if (collectionView == _weekCollectionView) {
        return [tool weeksFromDate:tool.minimumDate toDate:tool.maximumDate] + 1;
        
    } else if (collectionView == _dayItemCollectionView) {
        return 1;
        
    } else if (collectionView == _appearanceCollectionView) {
        return 1;
    }
    
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _monthCollectionView) {
        return 42;

    } else if (collectionView == _weekCollectionView) {
        return 7;
        
    } else if (collectionView == _dayItemCollectionView) {
        return [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date].count;
        
    } else if (collectionView == _appearanceCollectionView) {
        if (self.appearanceMode == SRMAppearanceEditStampMode) {
            return [[SRMStampStore sharedStore] allStampsPath].count;
            
        } else if (self.appearanceMode == SRMAppearanceEditThemeMode) {
            return [[SRMThemeStore sharedStore] allThemePath].count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _monthCollectionView) {
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
            [cell setClear];
            
        } else if (indexPath.row > blankDayCount + currentMonthDayCount - 1) {
            [cell setOtherMonthDate:indexPath.row - blankDayCount - currentMonthDayCount + 1];
            [cell setClear];
            
        } else {
            [cell setCurrentMonthDate:indexPath.row - blankDayCount + 1];
            
            if ([tool date:date isEqualToDate:_today]) {
                [cell setToday];
                
            } else if ([[SRMEventStore sharedStore] dayEvents:date].count > 0) {
                [cell setEvent];
                
            } else {
                [cell setClear];
            }
        
            
        }
    
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
        return cell;
        
    } else if (collectionView == _weekCollectionView) {
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
    } else if (collectionView == _dayItemCollectionView) {
        SRMDayScheduleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseDayScheduleCellIdentifier forIndexPath:indexPath];
        NSArray *items = [[SRMEventStore sharedStore] dayEventsNotAllDay:self.date];
        EKEvent *item = items[indexPath.row];
        
        [cell setEvent:item];
        
        return cell;
        
    } else if (collectionView == _appearanceCollectionView) {
        SRMAppearanceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseAppearanceCellIdentifier forIndexPath:indexPath];
        if (self.appearanceMode == SRMAppearanceEditStampMode) {
            [cell setStamp:indexPath.row];
            
        } else if (self.appearanceMode == SRMAppearanceEditThemeMode) {
            [cell setTheme:indexPath.row];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _weekCollectionView) {
        CGFloat cellWidth = _weekViewHeight;
        CGSize size = CGSizeMake(cellWidth, cellWidth);
        return size;
        
    } else if (collectionView == _appearanceCollectionView) {
        CGFloat cellWidth = _weekViewHeight;
        CGFloat cellHeight = collectionView.frame.size.height / 3.0;
        return CGSizeMake(cellWidth, cellHeight);
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _monthCollectionView) {
        if (kind == UICollectionElementKindSectionHeader) {
            SRMMonthBoardView *board = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseMonthBoardIdentifier forIndexPath:indexPath];

            SRMCalendarTool *tool = [SRMCalendarTool tool];
            NSDate *date = [tool dateByAddingMonths:indexPath.section toDate:tool.minimumDate];
            
            [board setYear:[tool yearOfDate:date] month:[tool monthOfDate:date]];
            [board setEditMode:self.viewMode == SRMCalendarEditViewMode ? YES : NO];
            [board.boardCollectionView reloadData];
            [board updateThemeAnimate:NO];
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
    if (collectionView == _monthCollectionView) {
        SRMMonthDayCell *cell = (SRMMonthDayCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([[SRMCalendarTool tool] monthOfDate:cell.date] != self.selectedMonth) {
            [self monthScrollToDate:cell.date animated:YES];
            self.date = cell.date;
            
        } else {
            self.date = cell.date;
            [self monthToWeek];
        }

    } else if (collectionView == _weekCollectionView) {
        SRMWeekDayCell *cell = (SRMWeekDayCell *)[collectionView cellForItemAtIndexPath:indexPath];
        self.date = cell.date;
        
    } else if (collectionView == _appearanceCollectionView && self.appearanceMode == SRMAppearanceEditThemeMode) {
        [[SRMThemeStore sharedStore] setTheme:indexPath.row forYear:_selectedYear month:_selectedMonth];
        [self selectTheme];
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
