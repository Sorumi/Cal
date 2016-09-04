//
//  SRMAddViewController.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import <EventKit/EventKit.h>
#import "SRMEventEditViewController.h"
#import "SRMSelectViewController.h"
#import "SRMSelectCalendarViewController.h"
#import "SRMRepeatEndViewController.h"
#import "SRMCalendarTool.h"
#import "SRMSwitch.h"
#import "SRMEventStore.h"
#import "SRMIconCell.h"
#import "SRMIconStore.h"
#import "SRMColorStore.h"

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMEventEditViewController () <UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SRMSwitchDelegate, SRMSelectViewDelegate, SRMRepeatEndDelegate>

@property (nonatomic) BOOL firstEditToggle;

@property (nonatomic, strong) NSArray *repeatType;
@property (nonatomic, strong) NSArray *reminderNotAllDayType;
@property (nonatomic, strong) NSArray *reminderAllDayType;

@property (nonatomic) SRMTimeSelectMode timeSelectMode;
@property (nonatomic) SRMEventRepeatMode repeatMode;
@property (nonatomic) SRMEventReminderMode reminderMode;

@property (nonatomic) NSInteger iconNum;
@property (nonatomic) NSInteger calendarNum;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *repeatEndDate;

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;

@property (weak, nonatomic) IBOutlet UITextField *titleText;

@property (weak, nonatomic) IBOutlet UILabel *calendarValueLabel;

@property (weak, nonatomic) IBOutlet UITextField *locationText;

@property (weak, nonatomic) IBOutlet UITextView *noteText;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet SRMSwitch *allDaySwitch;

@property (weak, nonatomic) IBOutlet UILabel *repeatValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatEndDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *reminderValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

#pragma mark - IBOutlet Icon

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) IBOutlet UILabel *calendarIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationIcon;
@property (weak, nonatomic) IBOutlet UILabel *noteIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateIcon;
@property (weak, nonatomic) IBOutlet UILabel *repeatIcon;
@property (weak, nonatomic) IBOutlet UILabel *reminderIcon;


#pragma mark - IBOutlet Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *repeatEndCell;

@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UICollectionView *iconSelectView;

@end

@implementation SRMEventEditViewController

static NSString * const reuseIconCellIdentifier = @"IconCell";

#pragma mark - Life Cycle & Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.repeatType = @[@"Never", @"Every Day", @"Every Week", @"Every 2 Weeks", @"Every Month", @"Every Year"];
    self.reminderNotAllDayType = @[@"None", @"On time of event", @"5 minutes before", @"15 minutes before", @"30 minutes before", @"1 hour before", @"1 day before"];
    self.reminderAllDayType = @[@"None", @"On the day of event", @"1 day before", @"2 days before", @"1 week before"];
    
    for (UIView *view in self.blockView) {
        // shadow
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0.5;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
    }
    
    self.noteText.textContainer.lineFragmentPadding = 0;
    
    [self.startLabel setHighlightedTextColor:self.view.tintColor];
    [self.endLabel setHighlightedTextColor:self.view.tintColor];
    
    _datePicker.subviews[0].subviews[1].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    _datePicker.subviews[0].subviews[2].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [_datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    
    // delegate
    self.noteText.delegate = self;
    self.allDaySwitch.delegate = self;
    
    // static table
    self.hideSectionsWithHiddenRows = YES;
    self.reloadTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.insertTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.deleteTableViewRowAnimation = UITableViewRowAnimationMiddle;
    
    [self cell:self.datePickerCell setHidden:YES];
    [self cell:self.repeatEndCell setHidden:YES];
    [self reloadDataAnimated:NO];
    
    // icon
    _iconButton.titleLabel.font = [UIFont iconfontOfSize:20];
    [_iconButton setTitle:[NSString iconfontIconStringForEnum:IFSquareSelect] forState:UIControlStateNormal];
    [_iconButton addTarget:self action:@selector(showIconKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    _calendarIcon.font = [UIFont iconfontOfSize:20];
    _calendarIcon.text = [NSString iconfontIconStringForEnum:IFCalendar];
    _calendarIcon.highlighted = YES;
    
    _locationIcon.font = [UIFont iconfontOfSize:20];
    _locationIcon.text = [NSString iconfontIconStringForEnum:IFLocation];
    
    _noteIcon.font = [UIFont iconfontOfSize:20];
    _noteIcon.text = [NSString iconfontIconStringForEnum:IFNote];
    
    _dateIcon.font = [UIFont iconfontOfSize:20];
    _dateIcon.text = [NSString iconfontIconStringForEnum:IFClock];
    _dateIcon.highlighted = YES;
    
    _repeatIcon.font = [UIFont iconfontOfSize:20];
    _repeatIcon.text = [NSString iconfontIconStringForEnum:IFRepeat];
    
    _reminderIcon.font = [UIFont iconfontOfSize:20];
    _reminderIcon.text = [NSString iconfontIconStringForEnum:IFBell];
    
    // icon select
    CGRect newframe = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _overlay = [[UIView alloc] initWithFrame:newframe];
    _overlay.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    _overlay.hidden = YES;
    [self.navigationController.view insertSubview:_overlay belowSubview:self.navigationController.navigationBar];
    UITapGestureRecognizer *tapOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideIconKeyboard)];
    [_overlay addGestureRecognizer:tapOverlay];
    
    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 200);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(30, 30, 30, 30);
    layout.itemSize = CGSizeMake(40, 40);
    _iconSelectView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _iconSelectView.backgroundColor = [UIColor whiteColor];
    _iconSelectView.bounces = NO;
    _iconSelectView.showsHorizontalScrollIndicator = NO;
    _iconSelectView.showsVerticalScrollIndicator = NO;
    _iconSelectView.dataSource = self;
    _iconSelectView.delegate = self;
    [_iconSelectView registerNib:[UINib nibWithNibName:@"SRMIconCell" bundle:nil] forCellWithReuseIdentifier:reuseIconCellIdentifier];
    [self.navigationController.view insertSubview:_iconSelectView belowSubview:self.navigationController.navigationBar];
    
    // init
    if (_event) {
        [self initWithEdit];
    } else {
        [self initWithNew];
    }
}

- (void)initWithNew
{
    self.title = @"New Event";
    
    self.startDate = [[SRMCalendarTool tool] dateOnHour:[NSDate date]];
    self.endDate = [[SRMCalendarTool tool] dateOnHour:[[SRMCalendarTool tool] dateByAddingHours:1 toDate:[NSDate date]]];
    
    self.timeSelectMode = SRMTimeSelectNone;
    self.repeatMode = SRMEventRepeatNever;
    self.reminderMode = SRMEventReminderNone;
    self.iconNum = 0;
    self.calendarNum = [[SRMEventStore sharedStore] defaultCalendarIndex];
    NSInteger num = [[SRMEventStore sharedStore] colorForCalendarIndex:self.calendarNum];
    self.view.tintColor = [[SRMColorStore sharedStore] colorForNum:num];
    [self tintColorDidChange];
}

- (void)initWithEdit
{
    self.title = @"Edit Event";

    _allDaySwitch.value = _event.allDay;
    self.startDate = _event.startDate;
    self.endDate = _event.endDate;
    _titleText.text = _event.title;
    _locationText.text = _event.location;
    _noteText.text = _event.notes;
    self.calendarNum = [[[SRMEventStore sharedStore] allCalendars] indexOfObject:_event.calendar];
    self.iconNum = [[SRMEventStore sharedStore] iconForEventIdentifier:_event.eventIdentifier];
    
    if (_event.recurrenceRules.count > 0) {
        EKRecurrenceRule *rule = _event.recurrenceRules[0];
        switch (rule.frequency) {
            case EKRecurrenceFrequencyDaily:
                self.repeatMode = SRMEventRepeatEveryDay;
                break;
            case EKRecurrenceFrequencyWeekly:
                if (rule.interval == 1) {
                    self.repeatMode = SRMEventRepeatEveryWeek;
                } else if (rule.interval == 2) {
                   self.repeatMode = SRMEventRepeatEveryTwoWeek;
                }
                break;
            case EKRecurrenceFrequencyMonthly:
                self.repeatMode = SRMEventRepeatEveryMonth;
                break;
            case EKRecurrenceFrequencyYearly:
                self.repeatMode = SRMEventRepeatEveryYear;
                break;
            default:
                break;
        }
        
        if (rule.recurrenceEnd) {
            EKRecurrenceEnd *end = rule.recurrenceEnd;
            self.repeatEndDate = end.endDate;
        }
    }
    
    if (_event.hasAlarms) {
        EKAlarm *alarm = _event.alarms[0];
        
        if (alarm.absoluteDate && _allDaySwitch.value) {
            NSDate *date = alarm.absoluteDate;
            
            NSInteger days =[[SRMCalendarTool tool] daysFromDate:date toDate:_event.startDate];
            
            switch (days) {
                case 0:
                    self.reminderMode = SRMEventReminderADOnDay;
                    break;
                case 1:
                    self.reminderMode = SRMEventReminderADOneDay;
                    break;
                case 2:
                    self.reminderMode = SRMEventReminderADTwoDay;
                    break;
                case 7:
                    self.reminderMode = SRMEventReminderADOneWeek;
                    break;
                    
                default:
                    break;
            }
            
        } else if (alarm.relativeOffset && !_allDaySwitch.value) {
            NSInteger minutes = alarm.relativeOffset / 60;
            
            switch (minutes) {
                case 0:
                    self.reminderMode = SRMEventReminderNADOnTime;
                    break;
                case -5:
                    self.reminderMode = SRMEventReminderNADFiveMin;
                    break;
                case -15:
                    self.reminderMode = SRMEventReminderNADFifteenMin;
                    break;
                case -30:
                    self.reminderMode = SRMEventReminderNADThirtyMin;
                    break;
                case -60:
                    self.reminderMode = SRMEventReminderNADOneHour;
                    break;
                case -60*24:
                    self.reminderMode = SRMEventReminderNADOneDay;
                    break;
    
                default:
                    break;
            }
        } else {
            self.reminderMode = SRMEventReminderNone;
        }
//        } else {
//            NSInteger minute = alarm.relativeOffset / 60;
//            date = [tool dateByAddingMinutes:minute toDate:_event.startDate];
//        }
//        NSString *text = [tool dateFormat:date];
//        text = [text stringByAppendingString:@" "];
//        text = [text stringByAppendingString:[tool timeFormat:date]];
//        _reminderLabel.text = text;
//        
//    } else {
//        [self cell:_reminderCell setHidden:YES];
    }

    
    
    NSInteger num = [[SRMEventStore sharedStore] colorForCalendarIndex:self.calendarNum];
    self.view.tintColor = [[SRMColorStore sharedStore] colorForNum:num];
    [self tintColorDidChange];
    
}

#pragma mark - Properties

- (void)setTimeSelectMode:(SRMTimeSelectMode)timeSelectMode
{
    NSDate *date;
    switch (timeSelectMode) {
        case SRMTimeSelectNone:
            _timeSelectMode = SRMTimeSelectNone;
            [self setDatePickerHidden:YES];
            [self.startLabel setHighlighted:NO];
            [self.endLabel setHighlighted:NO];
            break;
            
        case SRMTimeSelectStart:
            _timeSelectMode = SRMTimeSelectStart;
            [self setDatePickerHidden:NO];
            [self.startLabel setHighlighted:YES];
            [self.endLabel setHighlighted:NO];
            self.datePicker.minimumDate = nil;
            date = self.startDate;

            break;
            
        case SRMTimeSelectEnd:
            _timeSelectMode = SRMTimeSelectEnd;
            [self setDatePickerHidden:NO];
            [self.startLabel setHighlighted:NO];
            [self.endLabel setHighlighted:YES];
            self.datePicker.minimumDate = self.startDate;
            date = self.endDate;

            break;
    }
    
    __weak SRMEventEditViewController *weakSelf = self;
    
    if (timeSelectMode != SRMTimeSelectNone) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             weakSelf.datePicker.date = date;
                         }];
    }
}

- (void)setIconNum:(NSInteger)iconNum
{
    _iconNum = iconNum;
    NSInteger num = [[[SRMIconStore sharedStore] allIcons][iconNum] integerValue];
    [_iconButton setTitle:[NSString iconfontIconStringForEnum:num] forState:UIControlStateNormal];
}

- (void)setCalendarNum:(NSInteger)calendarNum
{
    _calendarNum = calendarNum;
    EKCalendar *calendar = [[SRMEventStore sharedStore] allCalendars][calendarNum];
    self.calendarValueLabel.text = calendar.title;
    NSInteger num = [[SRMEventStore sharedStore] colorForCalendarIdentifier:calendar.calendarIdentifier];
    self.tableView.tintColor = [[SRMColorStore sharedStore] colorForNum:num];
}

- (void)setRepeatMode:(SRMEventRepeatMode)repeatMode
{
    _repeatMode = repeatMode;
    self.repeatValueLabel.text = self.repeatType[repeatMode];
    if (_repeatMode != SRMTimeSelectNone) {
        _repeatIcon.highlighted = YES;
        [self cell:self.repeatEndCell setHidden:NO];
        [self reloadDataAnimated:YES];
    } else {
        _repeatIcon.highlighted = NO;
        [self cell:self.repeatEndCell setHidden:YES];
        [self reloadDataAnimated:YES];
    }
}

- (void)setRepeatEndDate:(NSDate *)repeatEndDate
{
    if (repeatEndDate) {
        _repeatEndDateLabel.text = [[SRMCalendarTool tool] dateDisplayFormat:repeatEndDate];
    } else {
        _repeatEndDateLabel.text = @"Never";
        _repeatEndDate = repeatEndDate;
    }
}

- (void)setReminderMode:(SRMEventReminderMode)reminderMode
{
    _reminderMode = reminderMode;
    self.reminderValueLabel.text = self.allDaySwitch.value ? self.reminderAllDayType[reminderMode] : self.reminderNotAllDayType[reminderMode];
    if (_reminderMode != SRMEventReminderNone) {
        _reminderIcon.highlighted = YES;
    } else {
        _reminderIcon.highlighted = NO;
    }
}

- (void)setStartDate:(NSDate *)date
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    self.startDateLabel.text = [tool dateDisplayFormat:date];
    
    if (!self.allDaySwitch.value) { // not all day
        self.startTimeLabel.text = [tool timeDisplayFormat:date];
    } else {
        self.startTimeLabel.text = [tool weekdayDisplayFormat:date];
    }
    
    _startDate = date;
    
    if ([_endDate timeIntervalSinceDate: _startDate] < 0) {
        self.endDate = _startDate;
    }
}

- (void)setEndDate:(NSDate *)date
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    self.endDateLabel.text = [tool dateDisplayFormat:date];
    
    if (!self.allDaySwitch.value) { // not all day
        self.endTimeLabel.text = [tool timeDisplayFormat:date];
    } else {
        self.endTimeLabel.text = [tool weekdayDisplayFormat:date];
    }
    _endDate = date;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"CalendarType"]) {
        SRMSelectCalendarViewController *vc = segue.destinationViewController;
        vc.selectMode = SRMEventSelectCalendar;
        vc.title = @"Calendar";
        vc.delegate = self;
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
        for (EKCalendar *calendar in [[SRMEventStore sharedStore] allCalendars]) {
            [titleArray addObject:calendar.title];
        }
        vc.titleArray = titleArray;
        vc.selectedRow = self.calendarNum;
        
    } else if ([segue.identifier isEqual: @"RepeatType"]) {
        SRMSelectViewController *vc = segue.destinationViewController;
        vc.selectMode = SRMEventSelectRepeat;
        vc.title = @"Repeat";
        vc.delegate = self;
        vc.titleArray = self.repeatType;
        vc.selectedRow = self.repeatMode;
        
    } else if ([segue.identifier isEqual: @"EndRepeat"]) {
        SRMRepeatEndViewController *vc = segue.destinationViewController;
        vc.delegate = self;

        if (self.repeatEndDate) {
            vc.date = self.repeatEndDate;
        }
    } else if ([segue.identifier isEqual: @"RemainderType"]) {
        SRMSelectViewController *vc = segue.destinationViewController;
        vc.selectMode = SRMEventSelectReminder;
        vc.title = @"Reminder";
        vc.delegate = self;
        vc.titleArray = self.allDaySwitch.value ? self.reminderAllDayType : self.reminderNotAllDayType;
        vc.selectedRow = self.reminderMode;
    }
}

#pragma mark - Action

- (void)showIconKeyboard
{
    [self.view endEditing:YES];
    CGRect frame = _iconSelectView.frame;
    if (frame.origin.y == self.view.frame.size.height) {
        frame.origin.y -= frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _iconSelectView.frame = frame;
                         }];
        [UIView transitionWithView:_overlay
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _overlay.hidden = NO;
                        }
                        completion:nil];
    }
}

- (void)hideIconKeyboard
{
    CGRect frame = _iconSelectView.frame;
    if (frame.origin.y == self.view.frame.size.height - frame.size.height) {
                frame.origin.y += frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _iconSelectView.frame = frame;
                         }];
        [UIView transitionWithView:_overlay
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _overlay.hidden = YES;
                        }
                        completion:nil];
    }
}

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)done:(id)sender
{
    if ([self.titleText.text isEqual: @""]) {
        // popover
    } else {
        EKRecurrenceRule *rule;

        if (self.repeatMode != SRMEventRepeatNever) {
            EKRecurrenceEnd *end;
            
            if (self.repeatEndDate) {
                end = [EKRecurrenceEnd recurrenceEndWithEndDate:self.repeatEndDate];
            } else {
                end = nil;
            }
            
            switch (self.repeatMode) {
                case SRMEventRepeatEveryDay:
                    rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:end];
                    break;
                case SRMEventRepeatEveryWeek:
                    rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:end];
                    break;
                case SRMEventRepeatEveryTwoWeek:
                    rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:2 end:end];
                    break;
                case SRMEventRepeatEveryMonth:
                    rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:end];
                    break;
                case SRMEventRepeatEveryYear:
                    rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:end];
                    break;
                default:
                    break;
            }
        }
        
        EKAlarm *alarm;
        
        if (self.reminderMode != SRMEventReminderNone) {
            if (self.allDaySwitch.value) {
                NSDate *date = [[SRMCalendarTool tool] date:self.startDate onDefiniteHour:9];
                
                switch (self.reminderMode) {
                    case SRMEventReminderADOnDay:
                        date = [[SRMCalendarTool tool] dateByAddingDays:0 toDate:date];
                        break;
                    case SRMEventReminderADOneDay:
                        date = [[SRMCalendarTool tool] dateByAddingDays:-1 toDate:date];
                        break;
                    case SRMEventReminderADTwoDay:
                        date = [[SRMCalendarTool tool] dateByAddingDays:-2 toDate:date];
                        break;
                    case SRMEventReminderADOneWeek:
                        date = [[SRMCalendarTool tool] dateByAddingDays:-7 toDate:date];
                        break;
                    default:
                        break;
                }
                alarm = [EKAlarm alarmWithAbsoluteDate:date];
                
            } else {
                switch (self.reminderMode) {
                    case SRMEventReminderNADOnTime:
                        alarm = [EKAlarm alarmWithRelativeOffset:0];
                        break;
                    case SRMEventReminderNADFiveMin:
                        alarm = [EKAlarm alarmWithRelativeOffset:-5 * 60];
                        break;
                    case SRMEventReminderNADFifteenMin:
                        alarm = [EKAlarm alarmWithRelativeOffset:-15 * 60];
                        break;
                    case SRMEventReminderNADThirtyMin:
                        alarm = [EKAlarm alarmWithRelativeOffset:-30 * 60];
                        break;
                    case SRMEventReminderNADOneHour:
                        alarm = [EKAlarm alarmWithRelativeOffset:-60 * 60];
                        break;
                    case SRMEventReminderNADOneDay:
                        alarm = [EKAlarm alarmWithRelativeOffset:-24 * 60  * 60];
                        break;
                    default:
                        break;
                }
            }
        }
        
        BOOL isSuccess;
        isSuccess = [[SRMEventStore sharedStore] editEvent:_event
                                                         title:_titleText.text
                                                     calendar:_calendarNum
                                                       allDay:_allDaySwitch.value
                                                    startDate:_startDate
                                                      endDate:_endDate
                                                     location:_locationText.text
                                                         note:_noteText.text
                                               recurrenceRule:rule
                                                        alarm:alarm
                                                         icon:_iconNum];
        
//        NSLog(isSuccess ? @"Event added in calendar" : @"Fail");

        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
}

- (IBAction)toggleStartDate:(id)sender
{
    if (self.timeSelectMode == SRMTimeSelectStart) {
        self.timeSelectMode = SRMTimeSelectNone;
        
    } else if (self.timeSelectMode == SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectStart;
        
    } else {
        self.timeSelectMode = SRMTimeSelectStart;
    }
    
}

- (IBAction)toggleEndTime:(id)sender
{
    if (self.timeSelectMode == SRMTimeSelectEnd) {
        self.timeSelectMode = SRMTimeSelectNone;
        
    } else if (self.timeSelectMode == SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectEnd;
        
    } else {
        self.timeSelectMode = SRMTimeSelectEnd;
    }
}

- (void)tintColorDidChange
{
    UIColor *color = self.view.tintColor;
    self.navigationController.navigationBar.barTintColor = color;
    
    _allDaySwitch.tintColor = color;
    _calendarIcon.highlightedTextColor = color;
    _locationIcon.highlightedTextColor = color;
    _noteIcon.highlightedTextColor = color;
    _dateIcon.highlightedTextColor = color;
    _repeatIcon.highlightedTextColor = color;
    _reminderIcon.highlightedTextColor = color;
    _startLabel.highlightedTextColor = color;
    _endLabel.highlightedTextColor = color;
}

#pragma mark - DatePicker

- (void)setDatePickerHidden:(BOOL)hidden
{
    [self cell:self.datePickerCell setHidden:hidden];
    [self reloadDataAnimated:YES];
}

- (void)datePickerChange:(UIDatePicker *)datePicker
{
    NSDate *date = datePicker.date;
    
    if (self.timeSelectMode == SRMTimeSelectStart) {
        [self setStartDate:date];
        
    } else if (self.timeSelectMode == SRMTimeSelectEnd) {
        [self setEndDate:date];
    }
}

#pragma mark - <SRMSelectViewDelegate>

- (void)selectView:(SRMEventSelectMode)selectMode didBackWithSelectRow:(NSInteger)selectRow
{
    if (selectMode == SRMEventSelectCalendar) {
        self.calendarNum = selectRow;
        self.view.tintColor = self.navigationController.navigationBar.barTintColor;
        [self tintColorDidChange];
        
    } else if (selectMode == SRMEventSelectRepeat) {
        self.repeatMode = selectRow;
        
    } else if (selectMode == SRMEventSelectReminder) {
        self.reminderMode = selectRow;
    }
}

#pragma mark - <SRMRepeatEndDelegate>

- (void)repeatEndViewDidBackWithDate:(NSDate *)endDate
{
    self.repeatEndDate = endDate;
}

#pragma mark - <SRMSwitchDelegate>

- (void)switchView:(SRMSwitch *)switchView didEndToggleWithValue:(BOOL)value
{
    __weak SRMEventEditViewController *weakSelf = self;
    if (value) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             weakSelf.datePicker.datePickerMode = UIDatePickerModeDate;
                         }];
        
    } else {
        [UIView animateWithDuration:0.3
                         animations:^{
                             weakSelf.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                             weakSelf.datePicker.minuteInterval = 5;
                         }];
        
    }
    
    if (_event && !_firstEditToggle) {
        self.startDate = [[SRMCalendarTool tool] dateOnHour:[NSDate date]];
        self.endDate = [[SRMCalendarTool tool] dateOnHour:[[SRMCalendarTool tool] dateByAddingHours:1 toDate:[NSDate date]]];
        _firstEditToggle = YES;
    } else {
        self.startDate = self.startDate;
        self.endDate = self.endDate;
    }

    self.reminderMode = SRMEventReminderNone;
    
    
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _locationText) {
        _locationIcon.highlighted = YES;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _locationText && [textField.text isEqual: @""]) {
        _locationIcon.highlighted = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - <UITextViewDelegate>

- (void)textViewDidChange:(UITextView *)textView
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [self scrollToCursorForTextView:textView]; // cursor
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.noteLabel.hidden = YES;
    _noteIcon.highlighted = YES;
    [self scrollToCursorForTextView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual: @""]) {
        self.noteLabel.hidden = NO;
        _noteIcon.highlighted = NO;
    }
}

#pragma mark - TextView

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath
{
    
    CGFloat textViewWidth = self.noteText.frame.size.width;
    
    CGSize size = [self.noteText sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height + 20;
}

- (void)scrollToCursorForTextView: (UITextView*)textView
{
    
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    cursorRect.size.height += 30;
    
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible: (CGRect)rect
{
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return MAX(80, [self textViewHeightForRowAtIndexPath:indexPath]);
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        return 70;
        
    } else if (indexPath.section == 2 && indexPath.row == 1 && self.timeSelectMode != SRMTimeSelectNone) {
        return 180;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideIconKeyboard];
    if (self.timeSelectMode != SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectNone;
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.titleText becomeFirstResponder];
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self.locationText becomeFirstResponder];
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self.noteText becomeFirstResponder];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[SRMIconStore sharedStore] allIcons].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRMIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIconCellIdentifier forIndexPath:indexPath];
    NSInteger num = [((NSNumber *)[[SRMIconStore sharedStore] allIcons][indexPath.row]) integerValue];
    [cell setIcon:num];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger num = [((NSNumber *)[[SRMIconStore sharedStore] allIcons][indexPath.row]) integerValue];
    self.iconNum = num;
    [self hideIconKeyboard];
}

#pragma mark - Others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
