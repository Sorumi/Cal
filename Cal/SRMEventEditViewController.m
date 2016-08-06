//
//  SRMAddViewController.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventEditViewController.h"
#import "SRMSelectViewController.h"
#import "SRMRepeatEndViewController.h"
#import "SRMCalendarTool.h"
#import "SRMSwitch.h"

@interface SRMEventEditViewController () <UITextFieldDelegate, UITextViewDelegate, SRMSwitchDelegate, SRMSelectViewDelegate, SRMRepeatEndDelegate>

@property (nonatomic, strong) NSArray *repeatType;
@property (nonatomic, strong) NSArray *reminderType;
@property (nonatomic, strong) NSArray *reminderAllDayType;

@property (nonatomic) SRMTimeSelectMode timeSelectMode;
@property (nonatomic) SRMEventRepeatMode repeatMode;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDate *repeatEndDate;

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;
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

#pragma mark - IBOutlet Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *repeatEndCell;

@end

@implementation SRMEventEditViewController

#pragma mark - Life Cycle & Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.repeatType = @[@"Never", @"Every Day", @"Every Week", @"Every 2 Weeks", @"Every Month", @"Every Year"];
    self.reminderType = @[@"None", @"On time of event", @"5 minutes before", @"15 minutes before", @"30 minutes before", @"1 hour before", @"1 day before", @"1 week before"];
    self.reminderAllDayType = @[@"None", @"On the day of event", @"1 day before", @"2 days before", @"1 week before"];
    
    self.title = @"Add Event";
    
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
    
    self.datePicker.subviews[0].subviews[1].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    self.datePicker.subviews[0].subviews[2].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [self.datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    
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
    
    // init - add
    self.startDate = [[SRMCalendarTool tool] dateOnHour:[NSDate date]];
    self.endDate = [[SRMCalendarTool tool] dateOnHour:[[SRMCalendarTool tool] dateByAddingHours:1 toDate:[NSDate date]]];
    
    self.timeSelectMode = SRMTimeSelectNone;
    self.repeatMode = SRMEventRepeatNever;
    
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

- (void)setRepeatMode:(SRMEventRepeatMode)repeatMode
{
    _repeatMode = repeatMode;
    self.repeatValueLabel.text = self.repeatType[repeatMode];
    if (_repeatMode != SRMTimeSelectNone) {
        [self cell:self.repeatEndCell setHidden:NO];
        [self reloadDataAnimated:YES];
    } else {
        [self cell:self.repeatEndCell setHidden:YES];
        [self reloadDataAnimated:YES];
    }
}

- (void)setStartDate:(NSDate *)date
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    self.startDateLabel.text = [tool dateFormat:date];
    
    if (!self.allDaySwitch.value) { // not all day
        self.startTimeLabel.text = [tool timeFormat:date];
    } else {
        self.startTimeLabel.text = [tool weekdayFormat:date];
    }
    
    _startDate = date;
}

- (void)setEndDate:(NSDate *)date
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    self.endDateLabel.text = [tool dateFormat:date];
    
    if (!self.allDaySwitch.value) { // not all day
        self.endTimeLabel.text = [tool timeFormat:date];
    } else {
        self.endTimeLabel.text = [tool weekdayFormat:date];
    }
    _endDate = date;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"RepeatType"]) {
        SRMSelectViewController *vc = segue.destinationViewController;
        vc.selectMode = SRMEventRepeat;
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

    }
}

#pragma mark - Action

- (IBAction)backToCalendar:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
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
    if (selectMode == SRMEventRepeat) {
        self.repeatMode = selectRow;
    }
}

#pragma mark - <SRMRepeatEndDelegate>

- (void)repeadEndViewDidBackWithDate:(NSDate *)endDate
{
    self.repeatEndDate = endDate;
    if (endDate) {
        self.repeatEndDateLabel.text = [[SRMCalendarTool tool] dateFormat:endDate];
    } else {
        self.repeatEndDateLabel.text = @"Never";
    }
}

#pragma mark - <UITextFieldDelegate>

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
    [self scrollToCursorForTextView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual: @""]) {
        self.noteLabel.hidden = NO;
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
    
    self.startDate = self.startDate;
    self.endDate = self.endDate;
    
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
    if (self.timeSelectMode != SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectNone;

    }
    if (indexPath.section == 1 && indexPath.row == 1) {
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

#pragma mark - Others
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
