//
//  SRMBoardStampCell.m
//  Cal
//
//  Created by Sorumi on 16/8/13.
//  Copyright © 2016年 Sorumi. All rights reserved.
//

#import "SRMBoardStampCell.h"
#import "SRMStamp.h"
#import "SRMStampStore.h"
#import "SRMMonthBoardView.h"

@interface SRMBoardStampCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *scaleButton;

@end

@implementation SRMBoardStampCell

- (void)awakeFromNib {
    // Initialization code
    
    UIPanGestureRecognizer *panStamp = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(moveStamp:)];
    [self addGestureRecognizer:panStamp];
    
    self.deleteButton.layer.cornerRadius = 6;
    self.deleteButton.hidden = YES;
    
    self.scaleButton.layer.cornerRadius = 6;
    self.scaleButton.hidden = YES;
    
    UIPanGestureRecognizer *scaleStamp = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(scaleStamp:)];
    [self.scaleButton addGestureRecognizer:scaleStamp];
}

- (void)setEditMode:(BOOL)isEditMode
{
    self.deleteButton.hidden = !isEditMode;
    self.scaleButton.hidden = !isEditMode;
}

- (void)setStamp:(SRMStamp *)stamp
{
    _stamp = stamp;
    self.imageView.image = [[SRMStampStore sharedStore] stampForName:stamp.name];
}

- (void)moveStamp:(UIPanGestureRecognizer *)gesture
{
//    if (gesture.state == UIGestureRecognizerStateBegan) {

//        UICollectionView *collectionView = (UICollectionView *)[self superview];
//        [collectionView selectItemAtIndexPath:[collectionView indexPathForCell:self] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
//    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture translationInView:self];
        
        CGFloat x = self.center.x + point.x;
        CGFloat y = self.center.y + point.y;
        
        self.center = CGPointMake(x, y);
        [gesture setTranslation:CGPointZero inView:self];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        _stamp.xProportion = self.center.x / self.superview.bounds.size.width;
        _stamp.yProportion = self.center.y / self.superview.bounds.size.height;
        [[SRMStampStore sharedStore] saveChanges];
    }
}

- (void)scaleStamp:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture translationInView:self];
        
        CGRect frame = self.frame;
        
        CGFloat p = MAX(point.x / frame.size.width, point.y / frame.size.height);
        
        CGFloat width = frame.size.width * (1 + p);
        CGFloat height = frame.size.height * (1 + p);
        
        if (width>24 && height>24) {
            frame.size.width = width;
            frame.size.height = height;
            self.frame = frame;
            
        }
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (IBAction)deleteStamp:(id)sender
{
    SRMMonthBoardView *board = (SRMMonthBoardView *)[[self superview] superview];
    [board deleteStamp:_stamp];
    [self removeFromSuperview];
}

@end
