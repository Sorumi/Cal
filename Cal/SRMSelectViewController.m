//
//  SRMEventRepeatViewController.m
//  Cal
//
//  Created by Sorumi on 16/8/5.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSelectViewController.h"
#import "SRMEventEditViewController.h"
#import "SRMSelectCell.h"

@interface SRMSelectViewController ()

@end

@implementation SRMSelectViewController

static NSString * const reuseCellIdentifier = @"SelectCell";
static NSString * const reuseDatePickerCellIdentifier = @"DatePickerCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"SRMSelectCell" bundle:nil] forCellReuseIdentifier:reuseCellIdentifier];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([_delegate respondsToSelector:@selector(selectView:didBackWithSelectRow:)]) {
        [_delegate selectView:self.selectMode didBackWithSelectRow:self.selectedRow];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SRMSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCellIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = self.titleArray[indexPath.row];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRow = indexPath.row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
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
