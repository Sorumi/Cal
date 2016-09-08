//
//  SRMSelectCalendarViewController.m
//  Cal
//
//  Created by Sorumi on 16/8/28.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMSelectCalendarViewController.h"
#import "SRMSelectCalendarCell.h"
#import "SRMEventStore.h"
#import "SRMColorStore.h"
#import "SRMIconCell.h"

@interface SRMSelectCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UICollectionView *colorSelectView;
@property (nonatomic) NSInteger selectColorRow;

@end

@implementation SRMSelectCalendarViewController

static NSString * const reuseCalendarCellIdentifier = @"SelectCalendarCell";
static NSString * const reuseIconCellIdentifier = @"IconCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SRMSelectCalendarCell" bundle:nil] forCellReuseIdentifier:reuseCalendarCellIdentifier];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideColorKeyboard];
    [[SRMEventStore sharedStore] saveCalendarColorChanges];
}

#pragma mark - Action

- (void)showColorKeyboard
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

#pragma mark - <UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    SRMSelectCalendarCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseCalendarCellIdentifier forIndexPath:indexPath];
    
    cell.titleLabel.text = self.titleArray[indexPath.row];
    NSInteger color = [[SRMEventStore sharedStore] colorForCalendarIndex:indexPath.row];
    cell.colorButton.backgroundColor = [[SRMColorStore sharedStore] colorForNum:color];
    cell.buttonAction = ^{
        [self showColorKeyboard];
        self.selectColorRow = indexPath.row;
    };
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    NSInteger num = [[SRMEventStore sharedStore] colorForCalendarIndex:indexPath.row];
    self.navigationController.navigationBar.barTintColor = [[SRMColorStore sharedStore] colorForNum:num];
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
    SRMSelectCalendarCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectColorRow inSection:0]];
    
    cell.colorButton.backgroundColor = [[SRMColorStore sharedStore] colorForNum:indexPath.row];
    [[SRMEventStore sharedStore] setColor:indexPath.row forCalendarIndex:self.selectColorRow];
    [self hideColorKeyboard];
    
    if (self.selectColorRow == self.selectedRow) {
        self.navigationController.navigationBar.barTintColor = [[SRMColorStore sharedStore] colorForNum:indexPath.row];
    }
}

@end
