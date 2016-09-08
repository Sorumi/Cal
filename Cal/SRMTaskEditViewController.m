//
//  SRMTaskEditViewController.m
//  Cal
//
//  Created by Sorumi on 16/9/6.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTaskEditViewController.h"
#import "SRMCalendarConstance.h"
#import "SRMCalendarTool.h"
#import "SRMSwitch.h"
#import "SRMTask.h"
#import "SRMTaskStore.h"
#import "SRMColorStore.h"
#import "SRMIconCell.h"

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMTaskEditViewController () <UITextFieldDelegate, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SRMSwitchDelegate>

@property (nonatomic) SRMTimeSelectMode timeSelectMode;

@property (nonatomic) NSInteger colorNum;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *dueDate;

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;

@property (weak, nonatomic) IBOutlet UITextField *titleText;

@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UITextView *noteText;

@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *dueDateButton;

@property (weak, nonatomic) IBOutlet SRMSwitch *startDateSwitch;
@property (weak, nonatomic) IBOutlet SRMSwitch *dueDateSwitch;


@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

#pragma mark - Icon

@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UILabel *noteIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateIcon;
@property (weak, nonatomic) IBOutlet UILabel *reminderIcon;


#pragma mark - IBOutlet Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;

@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UICollectionView *colorSelectView;

@end

@implementation SRMTaskEditViewController

static NSString * const reuseIconCellIdentifier = @"IconCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UIView *view in _blockView) {
        // shadow
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0.5;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
    }
    
    _noteText.textContainer.lineFragmentPadding = 0;
    
    [_startLabel setHighlightedTextColor:self.view.tintColor];
    [_dueLabel setHighlightedTextColor:self.view.tintColor];
    
    _datePicker.subviews[0].subviews[1].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    _datePicker.subviews[0].subviews[2].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    
    [_datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    // delegate
    _noteText.delegate = self;
    _titleText.delegate = self;
 
    // static table
    self.hideSectionsWithHiddenRows = YES;
    self.reloadTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.insertTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.deleteTableViewRowAnimation = UITableViewRowAnimationMiddle;
    
    [self cell:self.datePickerCell setHidden:YES];
    [self reloadDataAnimated:NO];
    
    _colorButton.titleLabel.font = [UIFont iconfontOfSize:6];
    [_colorButton setTitle:[NSString iconfontIconStringForEnum:IFTriangleSmall] forState:UIControlStateNormal];

    _noteIcon.font = [UIFont iconfontOfSize:20];
    _noteIcon.text = [NSString iconfontIconStringForEnum:IFNote];
    
    _dateIcon.font = [UIFont iconfontOfSize:20];
    _dateIcon.text = [NSString iconfontIconStringForEnum:IFClock];

    _reminderIcon.font = [UIFont iconfontOfSize:20];
    _reminderIcon.text = [NSString iconfontIconStringForEnum:IFBell];
    
    // color select
    CGRect newframe = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _overlay = [[UIView alloc] initWithFrame:newframe];
    _overlay.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    _overlay.hidden = YES;
    [self.navigationController.view insertSubview:_overlay belowSubview:self.navigationController.navigationBar];
    UITapGestureRecognizer *tapOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideColorKeyboard)];
    [_overlay addGestureRecognizer:tapOverlay];
    
    CGFloat width = (self.view.frame.size.width - 70 - 15*6) / 7;
    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, width*3+30+60);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 15;
    layout.minimumLineSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(30, 30, 30, 30);
    
    layout.itemSize = CGSizeMake(width, width);
    _colorSelectView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _colorSelectView.backgroundColor = [UIColor whiteColor];
    _colorSelectView.bounces = NO;
    _colorSelectView.showsHorizontalScrollIndicator = NO;
    _colorSelectView.showsVerticalScrollIndicator = NO;
    _colorSelectView.dataSource = self;
    _colorSelectView.delegate = self;
    [_colorSelectView registerNib:[UINib nibWithNibName:@"SRMIconCell" bundle:nil] forCellWithReuseIdentifier:reuseIconCellIdentifier];
    [self.navigationController.view insertSubview:_colorSelectView belowSubview:self.navigationController.navigationBar];
    
    
    /////
    [self initWithNew];
    
}

- (void)initWithNew
{
    _startDateSwitch.value = NO;
    _dueDateSwitch.value = NO;
    [self switchView:_startDateSwitch didEndToggleWithValue:NO];
    [self switchView:_dueDateSwitch didEndToggleWithValue:NO];
    
    self.startDate = [[SRMCalendarTool tool] dateByIgnoringTimeComponentsOfDate:[NSDate date]];
    self.dueDate = [[SRMCalendarTool tool] dateByIgnoringTimeComponentsOfDate:[[SRMCalendarTool tool] dateByAddingHours:1 toDate:[NSDate date]]];
    
    self.colorNum = 0;
    self.timeSelectMode = SRMTimeSelectNone;
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
            [self.dueLabel setHighlighted:NO];
            break;
            
        case SRMTimeSelectStart:
            _timeSelectMode = SRMTimeSelectStart;
            [self setDatePickerHidden:NO];
            [self.startLabel setHighlighted:YES];
            [self.dueLabel setHighlighted:NO];
            self.datePicker.minimumDate = nil;
            date = self.startDate;
            break;
            
        case SRMTimeSelectEnd:
            _timeSelectMode = SRMTimeSelectEnd;
            [self setDatePickerHidden:NO];
            [self.startLabel setHighlighted:NO];
            [self.dueLabel setHighlighted:YES];
            self.datePicker.minimumDate = self.startDate;
            date = self.dueDate;
            break;
    }
    if (timeSelectMode != SRMTimeSelectNone) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             _datePicker.date = date;
                         }];
    }
}

- (void)setColorNum:(NSInteger)colorNum
{
    _colorNum = colorNum;
    self.view.tintColor = [[SRMColorStore sharedStore] colorForNum:colorNum];
    
    UIColor *color = self.view.tintColor;
    _colorButton.backgroundColor = color;
    _startDateSwitch.tintColor = color;
    _dueDateSwitch.tintColor = color;
    _noteIcon.highlightedTextColor = color;
    _dateIcon.highlightedTextColor = color;
    _startLabel.highlightedTextColor = color;
    _dueLabel.highlightedTextColor = color;
    _reminderIcon.highlightedTextColor = color;
    
    self.navigationController.navigationBar.barTintColor = color;
}

- (void)setStartDate:(NSDate *)startDate
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    _startDateLabel.text = [NSString stringWithFormat:@"%@ %@", [tool dateDisplayFormat:startDate], [tool weekdayDisplayFormat:startDate]];
    
    _startDate = startDate;
    
    if ([_dueDate timeIntervalSinceDate: _startDate] < 0) {
        self.dueDate = _startDate;
    }
}

- (void)setDueDate:(NSDate *)dueDate
{
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    _dueDateLabel.text = [NSString stringWithFormat:@"%@ %@", [tool dateDisplayFormat:dueDate], [tool weekdayDisplayFormat:dueDate]];
    
    _dueDate = dueDate;
}

#pragma mark - Action

- (IBAction)showColorKeyboard
{
    CGRect frame = _colorSelectView.frame;
    if (frame.origin.y == self.view.frame.size.height) {
        frame.origin.y -= frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _colorSelectView.frame = frame;
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

- (void)hideColorKeyboard
{
    CGRect frame = _colorSelectView.frame;
    if (frame.origin.y == self.view.frame.size.height - frame.size.height) {
        frame.origin.y += frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             _colorSelectView.frame = frame;
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
    [[SRMTaskStore sharedStore] editTask:nil
                                   title:_titleText.text
                                    note:_noteText.text
                               startDate:_startDate
                                 dueDate:_dueDate
                                colorNum:_colorNum];
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

- (IBAction)toggleDueDate:(id)sender
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
        self.startDate = date;
    } else if (self.timeSelectMode == SRMTimeSelectEnd) {
        self.dueDate = date;
    }
}

#pragma mark - <SRMSwitchDelegate>

- (void)switchView:(SRMSwitch *)switchView didEndToggleWithValue:(BOOL)value
{
    if (switchView == _startDateSwitch) {
        _startDateButton.hidden = !value;
        _startDateLabel.hidden = !value;
        
    } else if (switchView == _dueDateSwitch) {
        _dueDateButton.hidden = !value;
        _dueDateLabel.hidden = !value;
    }
    
    _dateIcon.highlighted = _startDateSwitch.value || _dueDateSwitch.value;
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
    if (indexPath.section == 0 && indexPath.row == 1) {
        return MAX(80, [self textViewHeightForRowAtIndexPath:indexPath]);
        
    } else if (indexPath.section == 1 && indexPath.row == 2 ) {
        return 180;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self hideIconKeyboard];
    if (self.timeSelectMode != SRMTimeSelectNone) {
        self.timeSelectMode = SRMTimeSelectNone;
    }
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        [self.titleText becomeFirstResponder];
//        
//    } else if (indexPath.section == 1 && indexPath.row == 0) {
//        [self.locationText becomeFirstResponder];
//        
//    } else if (indexPath.section == 1 && indexPath.row == 1) {
//        [self.noteText becomeFirstResponder];
//    }
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
    return [[SRMColorStore sharedStore] allColors].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SRMIconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIconCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [[SRMColorStore sharedStore] colorForNum:indexPath.row];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.colorNum = indexPath.row;
    [self hideColorKeyboard];
}


#pragma mark - Other

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
