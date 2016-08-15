//
//  SRMEventDetailViewController.m
//  Cal
//
//  Created by Sorumi on 16/8/15.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMEventDetailViewController.h"
#import "SRMCalendarTool.h"

@interface SRMEventDetailViewController ()

@property (nonatomic, strong) NSArray *repeatType;

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;
@property (nonatomic) IBOutletCollection(UIImageView) NSArray *iconImage;

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

#pragma mark - Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *noteCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *repeatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *endRepeatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *reminderCell;

@end

@implementation SRMEventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    self.repeatType = @[@"Never", @"Every Day", @"Every Week", @"Every 2 Weeks", @"Every Month", @"Every Year"];
    
    // tool bar
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"system_icon_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteEvent:)];
    
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"system_icon_delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteEvent:)];
    
    self.toolbarItems = [NSArray arrayWithObjects:editButton,
                         [self barButtonSystemItem:UIBarButtonSystemItemFlexibleSpace],
                         deleteButton, nil];
    // shadow
    for (UIView *view in self.blockView) {
        
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0.5;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
    }
    
    for (UIImageView *view in self.iconImage) {
        view.image = [view.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    // information
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    _titleLabel.text = _event.title;
    _calendarLabel.text = _event.calendar.title;
    
    if (![_event.location isEqual:@""]) {
        _locationLabel.text = _event.location;
    } else {
        [self cell:_locationCell setHidden:YES];
    }
    
    if (_event.notes) {
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
    
    if (_event.recurrenceRules.count > 0) {
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
    
    if (_event.alarms.count > 0) {
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
    
}

- (UIBarButtonItem*)barButtonSystemItem:(UIBarButtonSystemItem)systemItem
{
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:nil];
    return button;
}


#pragma mark - Action

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (void)deleteEvent:(id)sender
{
    
}

- (CGFloat)heightForLabel:(UILabel *)label
{
    CGSize neededSize = [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 80, FLT_MAX)];
    return neededSize.height;
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
        MAX([self heightForLabel:_noteLabel] + 24, 44);
        
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        return MAX([self heightForLabel:_noteLabel] + 24, 44);
        
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
