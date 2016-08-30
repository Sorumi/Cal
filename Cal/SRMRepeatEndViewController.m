//
//  SRMRepeatEndViewController.m
//  Cal
//
//  Created by Sorumi on 16/8/6.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMRepeatEndViewController.h"
#import "SRMCalendarTool.h"

#import "UIFont+IconFont.h"
#import "NSString+IconFont.h"

@interface SRMRepeatEndViewController ()

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;
@property (weak, nonatomic) IBOutlet UILabel *neverCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateCheckLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

#pragma mark - IBOutlet Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;

@end

@implementation SRMRepeatEndViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"End Repeat";
    
    for (UIView *view in self.blockView) {
        // shadow
        CALayer *layer = view.layer;
        layer.shadowOffset = CGSizeMake(0, 0);
        layer.shadowRadius = 0.5;
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.shadowOpacity = 0.3;
    }
    
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.subviews[0].subviews[1].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    _datePicker.subviews[0].subviews[2].backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [_datePicker addTarget:self action:@selector(datePickerChange:) forControlEvents:UIControlEventValueChanged];
    
    // static table
    self.hideSectionsWithHiddenRows = YES;
    self.reloadTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.insertTableViewRowAnimation = UITableViewRowAnimationMiddle;
    self.deleteTableViewRowAnimation = UITableViewRowAnimationMiddle;
    
    [self initilization];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([_delegate respondsToSelector:@selector(repeatEndViewDidBackWithDate:)]) {
        [_delegate repeatEndViewDidBackWithDate:self.date];
    }
}

- (void)initilization
{
    _neverCheckLabel.font = [UIFont iconfontOfSize:20];
    _dateCheckLabel.font = [UIFont iconfontOfSize:20];
    if (_date) {
        _neverCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
        _dateCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareCheck];
        self.dateLabel.text = [[SRMCalendarTool tool] dateFormat:self.date];
        self.datePicker.date = self.date;
        
    } else {
        _neverCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareCheck];
        _dateCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
        [self cell:self.datePickerCell setHidden:YES];
        [self reloadDataAnimated:NO];
    }
}


- (void)setEndDate:(BOOL)isEndDate
{
    if (isEndDate) {
        _neverCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
        _dateCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareCheck];
        self.date = self.datePicker.date;
        self.dateLabel.text = [[SRMCalendarTool tool] dateFormat:self.date];
        [self setDatePickerHidden:NO];
        
    } else {
        _neverCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareCheck];
        _dateCheckLabel.text = [NSString iconfontIconStringForEnum:IFSquareBlank];
        self.date = nil;
        self.dateLabel.text = @"On date";
        [self setDatePickerHidden:YES];
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
    self.date = datePicker.date;
    self.dateLabel.text = [[SRMCalendarTool tool] dateFormat:datePicker.date];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self setEndDate:NO];
        
    } else if (indexPath.row == 1) {
        [self setEndDate:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        return 180;
    }
    return 44;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
