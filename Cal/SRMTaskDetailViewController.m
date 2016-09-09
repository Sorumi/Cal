//
//  SRMTaskDetailTableViewController.m
//  Cal
//
//  Created by Sorumi on 16/9/8.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMTaskDetailViewController.h"
#import "SRMTaskEditViewController.h"
#import "SRMTaskStore.h"
#import "SRMCalendarTool.h"
#import "SRMTask.h"
#import "SRMColorStore.h"
#import "SRMSlideAlertView.h"

#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"

@interface SRMTaskDetailViewController () <SRMSlideAlertDelegate>

#pragma mark - IBOutlet

@property (nonatomic) IBOutletCollection(UIView) NSArray *blockView;
@property (nonatomic) IBOutletCollection(UILabel) NSArray *icons;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;

#pragma mark - Icon

@property (weak, nonatomic) IBOutlet UILabel *colorLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateIcon;
@property (weak, nonatomic) IBOutlet UILabel *reminderIcon;

#pragma marl - Cell

@property (weak, nonatomic) IBOutlet UITableViewCell *noteCell;

@property (nonatomic, strong) SRMSlideAlertView *deleteAlertView;
@property (nonatomic, strong) UIView *overlay;

@end

@implementation SRMTaskDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    for (UILabel *icon in _icons) {
        icon.font = [UIFont iconfontOfSize:20];
        icon.highlighted = YES;
    }
    
    _noteIcon.text = [NSString iconfontIconStringForEnum:IFNote];
    _dateIcon.text = [NSString iconfontIconStringForEnum:IFClock];
    _reminderIcon.text = [NSString iconfontIconStringForEnum:IFBell];
    
    // delete alert
    CGRect newframe = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _overlay = [[UIView alloc] initWithFrame:newframe];
    _overlay.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    _overlay.hidden = YES;
    [self.navigationController.view insertSubview:_overlay belowSubview:self.navigationController.navigationBar];
    UITapGestureRecognizer *tapOverlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDeleteAlert)];
    [_overlay addGestureRecognizer:tapOverlay];
    
    _deleteAlertView = [[SRMSlideAlertView alloc] initWithTitle:nil normalButton:@[@"Delete"] warnButton:@[@"Cancel"]];
    
    _deleteAlertView.delegate = self;
    [self.navigationController.view addSubview:_deleteAlertView];

    
    //
    [self initWithTask];
}

- (void)initWithTask
{
    // color
    UIColor *color = [[SRMColorStore sharedStore] colorForNum:_task.colorNum];
    self.view.tintColor = color;
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.toolbar.barTintColor = color;
    
    for (UILabel *icon in _icons) {
        icon.highlightedTextColor = color;
    }
    _colorLabel.backgroundColor = color;
    
    // information
    SRMCalendarTool *tool = [SRMCalendarTool tool];
    
    _titleLabel.text = _task.title;
    
    if (![_task.notes isEqual:@""]) {
        _noteLabel.text = _task.notes;
        [self cell:_noteCell setHidden:NO];
    } else {
        [self cell:_noteCell setHidden:YES];
    }
    
    _startDateLabel.text = _task.startDate ? [NSString stringWithFormat:@"%@ %@", [tool dateDisplayFormat:_task.startDate], [tool weekdayDisplayFormat:_task.startDate]] : @"";
    _dueDateLabel.text = _task.dueDate ? [NSString stringWithFormat:@"%@ %@", [tool dateDisplayFormat:_task.dueDate], [tool weekdayDisplayFormat:_task.dueDate]] : @"";
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
    UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"TaskEditNavigation"];
    SRMTaskEditViewController *vc = nvc.viewControllers[0];
    vc.task = _task;
    __weak SRMTaskDetailViewController *weakSelf = self;
    
    vc.didEdit = ^{
        [weakSelf initWithTask];
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:nvc animated:YES completion:nil];
    });
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
    
    if (buttonNum == 0) {
        isSuccess = [[SRMTaskStore sharedStore] deleteTask:_task];
        
    } else {
        [self hideDeleteAlert];
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
        return ![_task.notes isEqual:@""] ? MAX([self heightForLabel:_noteLabel] + 24, 44) : 0;
//
//    } else if (indexPath.section == 1 && indexPath.row == 0) {
//        return ![_event.location isEqual:@""] ?
//        MAX([self heightForLabel:_locationLabel] + 24, 44) :
//        (![_event.notes isEqual:@""] ?
//         MAX([self heightForLabel:_noteLabel] + 24, 44) : 0);
//        
//    } else if (indexPath.section == 1 && indexPath.row == 1) {
//        return ![_event.notes isEqual:@""] ? MAX([self heightForLabel:_noteLabel] + 24, 44) : 0;
//        
//    } else if (indexPath.section == 2 && indexPath.row == 0) {
//        return 70;
//        
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 1 && [_event.location isEqual:@""] && !_event.notes) {
//        return 0.1;
//        
//    } else if (section == 3 && _event.recurrenceRules.count == 0) {
//        return 0.1;
//    }
    return 10;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
