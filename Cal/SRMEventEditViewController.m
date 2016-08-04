//
//  SRMAddViewController.m
//  Cal
//
//  Created by Sorumi on 16/7/30.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventEditViewController.h"
#import "SRMCalendarTool.h"
#import "SRMSwitch.h"

typedef NS_ENUM(NSInteger, SRMTimeSelectMode) {
    SRMTimeSelectNone   = 0,
    SRMTimeSelectStart  = 1,
    SRMTimeSelectEnd    = 2
};

@interface SRMEventEditViewController () <UITextViewDelegate, SRMSwitchDelegate>

@property (nonatomic) SRMTimeSelectMode timeSelectMode;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

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

#pragma mark - IBOutlet Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;

@end

@implementation SRMEventEditViewController

#pragma mark - Life Cycle & Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.title = @"Add Event";
    
    CGRect frame = self.tableView.tableHeaderView.frame;
    frame.size.height = 10;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];

    for (UIView *view in self.blockView) {
        // shadow
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0.5;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
    }
    
    self.noteText.textContainer.lineFragmentPadding = 0;
    
    self.datePicker.subviews[0].subviews[1].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    self.datePicker.subviews[0].subviews[2].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [self.datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    
    // delegate
    self.noteText.delegate = self;
    self.allDaySwitch.delegate = self;
    
    // static table
    self.timeSelectMode = SRMTimeSelectNone;
    self.hideSectionsWithHiddenRows = YES;
    self.reloadTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.insertTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.deleteTableViewRowAnimation = UITableViewRowAnimationMiddle;
    [self cell:self.datePickerCell setHidden:YES];
    [self reloadDataAnimated:NO];
    
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
        self.startLabel.textColor = [UIColor lightGrayColor];
        [self setDatePickerHidden:YES];
        
    } else if (self.timeSelectMode == SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectStart;
        self.startLabel.textColor = self.startLabel.tintColor;
        [self setDatePickerHidden:NO];
        
    } else {
        self.startLabel.textColor = self.startLabel.tintColor;
        self.endLabel.textColor = [UIColor lightGrayColor];
        self.timeSelectMode = SRMTimeSelectStart;
    }
    
}

- (IBAction)toggleEndTime:(id)sender
{
    if (self.timeSelectMode == SRMTimeSelectEnd) {
        self.timeSelectMode = SRMTimeSelectNone;
        self.endLabel.textColor = [UIColor lightGrayColor];
        [self setDatePickerHidden:YES];
        
    } else if (self.timeSelectMode == SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectEnd;
        self.endLabel.textColor = self.endLabel.tintColor;
        [self setDatePickerHidden:NO];
        
    } else {
        self.endLabel.textColor = self.endLabel.tintColor;
        self.startLabel.textColor = [UIColor lightGrayColor];
        self.timeSelectMode = SRMTimeSelectEnd;
    }
}

- (void)setDatePickerHidden:(BOOL)hidden
{
    [self cell:self.datePickerCell setHidden:hidden];
    [self reloadDataAnimated:YES];
}

- (void)datePickerChange:(UIDatePicker *)datePicker
{
//    NSLog(@"Selected date = %@", datePicker.date);
    
    NSDate *date = datePicker.date;
    
    if (self.timeSelectMode == SRMTimeSelectStart) {
        [self setStartDate:date withAllDay:self.allDaySwitch.value];
    } else if (self.timeSelectMode == SRMTimeSelectEnd) {
        [self setEndDate:date withAllDay:self.allDaySwitch.value];
    }
    
}

- (void)setStartDate:(NSDate *)date withAllDay:(BOOL)isAllDay
{
    SRMCalendarTool *tool = [[SRMCalendarTool alloc] init];
    
    self.startDateLabel.text = [tool dateFormat:date];
    
    if (!self.allDaySwitch.value) { // not all day
        self.startTimeLabel.text = [tool timeFormat:date];
    } else {
        self.startTimeLabel.text = [tool weekdayFormat:date];
    }
}

- (void)setEndDate:(NSDate *)date withAllDay:(BOOL)isAllDay
{
    SRMCalendarTool *tool = [[SRMCalendarTool alloc] init];
    
    self.endDateLabel.text = [tool dateFormat:date];
    
    if (!self.allDaySwitch.value) { // not all day
        self.endTimeLabel.text = [tool timeFormat:date];
    } else {
        self.endTimeLabel.text = [tool weekdayFormat:date];
    }
}

#pragma mark - <UITextViewDelegate>

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath
{
 
    CGFloat textViewWidth = self.noteText.frame.size.width;

    CGSize size = [self.noteText sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height + 20;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [self scrollToCursorForTextView:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqual: @""]) {
        self.noteLabel.hidden = NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.noteLabel.hidden = YES;
    [self scrollToCursorForTextView:textView];
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
//    NSLog(value ? @"YES" : @"NO");
    if (value) {
        [UIView animateWithDuration:0.3
                         animations:^{
                            self.datePicker.datePickerMode = UIDatePickerModeDate;
                         }];

    } else {
        [UIView animateWithDuration:0.3
                         animations:^{
                            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                         }];

    }
    
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
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        [self.noteText becomeFirstResponder];
    }
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
