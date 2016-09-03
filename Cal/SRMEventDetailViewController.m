//
//  SRMEventDetailViewController.m
//  Cal
//
//  Created by Sorumi on 16/8/15.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventDetailViewController.h"
#import "SRMEventEditViewController.h"
#import "SRMCalendarTool.h"
#import "SRMEventStore.h"
#import "SRMIconStore.h"
#import "SRMColorStore.h"
#import "SRMSlideAlertView.h"

#import "UIFont+IconFont.h"
#import "NSString+IconFont.h"

@interface SRMEventDetailViewController () <SRMSlideAlertDelegate>

@property (nonatomic, strong) NSArray *repeatType;

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;
@property (nonatomic) IBOutletCollection(UILabel) NSArray *icons;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *calendarLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *endRepeatLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

#pragma mark - IBOutlet Icon

@property (weak, nonatomic) IBOutlet UILabel *eventIcon;
@property (weak, nonatomic) IBOutlet UILabel *calendarIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationIcon;
@property (weak, nonatomic) IBOutlet UILabel *noteIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateIcon;
@property (weak, nonatomic) IBOutlet UILabel *repeatIcon;
@property (weak, nonatomic) IBOutlet UILabel *reminderIcon;

#pragma mark - Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *noteCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *repeatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endRepeatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reminderCell;

@property (nonatomic, strong) SRMSlideAlertView *deleteAlertView;
@property (nonatomic, strong) UIView *overlay;

@end

@implementation SRMEventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    self.repeatType = @[@"Never", @"Every Day", @"Every Week", @"Every 2 Weeks", @"Every Month", @"Every Year"];
    
    // tool bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:[NSString iconfontIconStringForEnum:IFEdit] style:UIBarButtonItemStylePlain target:self action:@selector(editEvent)];
    [editButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont iconfontOfSize:20]
                                         }
                              forState:UIControlStateNormal];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:[NSString iconfontIconStringForEnum:IFTrashCan] style:UIBarButtonItemStylePlain target:self action:@selector(deleteEvent)];
    [deleteButton setTitleTextAttributes:@{
                                         NSFontAttributeName: [UIFont iconfontOfSize:20]
                                         }
                              forState:UIControlStateNormal];
    
    UIBarButtonItem *fixedSpaceItem = [self barButtonSystemItem:UIBarButtonSystemItemFixedSpace];
    [fixedSpaceItem setWidth:10.0f];

    self.toolbarItems = [NSArray arrayWithObjects:
                         fixedSpaceItem,
                         editButton,
                         [self barButtonSystemItem:UIBarButtonSystemItemFlexibleSpace],
                         deleteButton,
                         fixedSpaceItem,
                         nil];
    // shadow
    for (UIView *view in self.blockView) {
        
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0.5;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
    }
    
    // icon
    NSInteger num = [[SRMEventStore sharedStore] colorForCalendarIdentifier:_event.calendar.calendarIdentifier];
    self.view.tintColor = [[SRMColorStore sharedStore] colorForNum:num];;
    UIColor *color = self.view.tintColor;
    
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.toolbar.barTintColor = color;
    
    for (UILabel *icon in _icons) {
        icon.font = [UIFont iconfontOfSize:20];
        icon.highlightedTextColor = color;
        icon.highlighted = YES;
    }

    NSInteger iconNum = [[SRMEventStore sharedStore] iconForEventIdentifier:_event.eventIdentifier];
    _eventIcon.text = [NSString iconfontIconStringForEnum:[[SRMIconStore sharedStore] iconForNum:iconNum]];
    _calendarIcon.text = [NSString iconfontIconStringForEnum:IFCalendar];
    _locationIcon.text = [NSString iconfontIconStringForEnum:IFLocation];
    _noteIcon.text = [NSString iconfontIconStringForEnum:IFNote];
    _dateIcon.text = [NSString iconfontIconStringForEnum:IFClock];
    _repeatIcon.text = [NSString iconfontIconStringForEnum:IFRepeat];
    _reminderIcon.text = [NSString iconfontIconStringForEnum:IFBell];
    
    // information
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    _titleLabel.text = _event.title;
    _calendarLabel.text = _event.calendar.title;
    
    if (![_event.location isEqual:@""]) {
        _locationLabel.text = _event.location;
    } else {
        [self cell:_locationCell setHidden:YES];
    }
    
    if (_event.hasNotes) {
        _noteLabel.text = _event.notes;
         [self cell:_noteCell setHeight:[self heightForLabel:_noteLabel]];
    } else {
        [self cell:_noteCell setHidden:YES];
    }
    
    _startDateLabel.text = [tool dateFormat:_event.startDate];
    _endDateLabel.text = [tool dateFormat:_event.endDate];
    
    if (_event.allDay) {
        _startTimeLabel.text = [tool weekdayFormat:_event.startDate];
        _endTimeLabel.text = [tool weekdayFormat:_event.endDate];
    } else {
        _startTimeLabel.text = [tool timeFormat:_event.startDate];
        _endTimeLabel.text = [tool timeFormat:_event.endDate];
    }
    
    if (_event.hasRecurrenceRules) {
        EKRecurrenceRule *rule = _event.recurrenceRules[0];
        switch (rule.frequency) {
            case EKRecurrenceFrequencyDaily:
                _repeatLabel.text = _repeatType[1];
                break;
            case EKRecurrenceFrequencyWeekly:
                if (rule.interval == 1) {
                    _repeatLabel.text = _repeatType[2];
                } else if (rule.interval == 2) {
                    _repeatLabel.text = _repeatType[3];
                }
                break;
            case EKRecurrenceFrequencyMonthly:
                _repeatLabel.text = _repeatType[4];
                break;
            case EKRecurrenceFrequencyYearly:
                _repeatLabel.text = _repeatType[5];
                break;
            default:
                break;
        }
        
        if (rule.recurrenceEnd) {
            EKRecurrenceEnd *end = rule.recurrenceEnd;
            _endRepeatLabel.text = [tool dateFormat:end.endDate];
        } else {
            [self cell:_endRepeatCell setHidden:YES];
        }
    } else {
        [self cell:_repeatCell setHidden:YES];
        [self cell:_endRepeatCell setHidden:YES];
    }
    
    if (_event.hasAlarms) {
        EKAlarm *alarm = _event.alarms[0];
        NSDate *date;
        if (alarm.absoluteDate) {
            date = alarm.absoluteDate;
        } else {
            NSInteger minute = alarm.relativeOffset / 60;
            date = [tool dateByAddingMinutes:minute toDate:_event.startDate];
        }
            NSString *text = [tool dateFormat:date];
            text = [text stringByAppendingString:@" "];
            text = [text stringByAppendingString:[tool timeFormat:date]];
            _reminderLabel.text = text;
    
    } else {
        [self cell:_reminderCell setHidden:YES];
    }
    
    [self reloadDataAnimated:NO];
    
    // delete alert
    CGRect newframe = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _overlay = [[UIView alloc] initWithFrame:newframe];
    _overlay.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    _overlay.hidden = YES;
    [self.navigationController.view insertSubview:_overlay belowSubview:self.navigationController.navigationBar];
    UITapGestureRecognizer *tapOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteAlert)];
    [_overlay addGestureRecognizer:tapOverlay];
    
    if (_event.recurrenceRules.count > 0) {
        _deleteAlertView = [[SRMSlideAlertView alloc] initWithTitle:@"This is a repeating event." normalButton:@[@"Delete this event only", @"Delete all future events"] warnButton:@[@"Cancel"]];
    } else {
        _deleteAlertView = [[SRMSlideAlertView alloc] initWithTitle:nil normalButton:@[@"Delete"] warnButton:@[@"Cancel"]];
    }

    _deleteAlertView.delegate = self;
    [self.navigationController.view addSubview:_deleteAlertView];
    
}

- (UIBarButtonItem*)barButtonSystemItem:(UIBarButtonSystemItem)systemItem
{
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:nil];
    return button;
}

#pragma mark - Action

- (void)showDeleteAlert
{
    CGRect frame = _deleteAlertView.frame;
    CGFloat toolBarHeight = self.navigationController.toolbar.frame.size.height;
    if (frame.origin.y == self.view.frame.size.height + toolBarHeight) {
        frame.origin.y -= frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _deleteAlertView.frame = frame;
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

- (void)hideDeleteAlert
{
    CGRect frame = _deleteAlertView.frame;
        CGFloat toolBarHeight = self.navigationController.toolbar.frame.size.height;
    if (frame.origin.y == self.view.frame.size.height + toolBarHeight - frame.size.height) {
        frame.origin.y += frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _deleteAlertView.frame = frame;
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

- (void)editEvent
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"EditNavigation"];
    SRMEventEditViewController *vc = nvc.viewControllers[0];
    vc.event = _event;
    __weak SRMEventDetailViewController *weakSelf = self;
    vc.didDismiss = ^{
        [weakSelf cancel:nil];
    };
    
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)deleteEvent
{
    [self showDeleteAlert];
}

- (CGFloat)heightForLabel:(UILabel *)label
{
    CGSize neededSize = [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 80, FLT_MAX)];
    return neededSize.height;
}

#pragma mark - <SRMSlideAlertDelegate>

- (void)didClickOnButton:(NSInteger)buttonNum
{
    BOOL isSuccess = NO;
    if (_event.recurrenceRules.count > 0) {
        if (buttonNum == 0) {
            isSuccess = [[SRMEventStore sharedStore] deleteThisEvent:self.event.eventIdentifier];
            
        } else if (buttonNum == 1) {
            isSuccess = [[SRMEventStore sharedStore] deleteFutureEvent:self.event.eventIdentifier];
        } else {
            [self hideDeleteAlert];
        }
    } else {
        if (buttonNum == 0) {
            isSuccess = [[SRMEventStore sharedStore] deleteThisEvent:self.event.eventIdentifier];
            
        } else {
            [self hideDeleteAlert];
        }
    }
    
    if (isSuccess) {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return MAX([self heightForLabel:_titleLabel] + 24, 44);
        
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        return MAX([self heightForLabel:_calendarLabel] + 24, 44);
        
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return ![_event.location isEqual:@""] ?
        MAX([self heightForLabel:_locationLabel] + 24, 44) :
        (![_event.notes isEqual:@""] ?
         MAX([self heightForLabel:_noteLabel] + 24, 44) : 0);
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        return ![_event.notes isEqual:@""] ? MAX([self heightForLabel:_noteLabel] + 24, 44) : 0;
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        return 70;

    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 && [_event.location isEqual:@""] && !_event.notes) {
        return 0.1;
        
    } else if (section == 3 && _event.recurrenceRules.count == 0) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
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
