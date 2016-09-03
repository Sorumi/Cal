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

#import "ColorUtils.h"

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
    
    self.deleteButton.layer.cornerRadius = 10;
    self.deleteButton.hidden = YES;
    
    self.scaleButton.layer.cornerRadius = 10;
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
    self.imageView.alpha = 0.8;
    
//    [self setNeedsDisplay];
}

//- (void)drawRect:(CGRect)rect
//{
//    CGFloat width = _imageView.image.size.width;
//    CGFloat height = _imageView.image.size.height;
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithString:@"DDDDDD"].CGColor);
//    CGFloat dash[] = {3, 4};
//    CGContextSetLineWidth(context, 0.5f);
//    CGContextSetLineDash(context, 0, dash, 2);
//    
//    CGContextMoveToPoint(context, 10, 10);
//    CGContextAddLineToPoint(context, width+10, 10);
//    CGContextAddLineToPoint(context, width+10, height+10);
//    CGContextAddLineToPoint(context, 10, height+10);
//    CGContextAddLineToPoint(context, 10, 10);
//    
//    
//    CGContextStrokePath(context);
//}

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
        
        CGRect bounds = self.bounds;
        
        CGFloat p = MAX(point.x / bounds.size.width, point.y / bounds.size.height);
        
        CGFloat width = bounds.size.width * (1 + p);
        CGFloat height = bounds.size.height * (1 + p);
        
        if (width>40 && height>40) {
            bounds.size.width = width;
            bounds.size.height = height;
            CGFloat x = self.center.x + bounds.size.width * p / 2;
            CGFloat y = self.center.y + bounds.size.height * p / 2;
            self.bounds = bounds;
            self.center = CGPointMake(x, y);
            
        }
        [gesture setTranslation:CGPointZero inView:self];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        _stamp.xScale = (self.bounds.size.width-20) / _imageView.image.size.width;
        _stamp.yScale = (self.bounds.size.height-20) / _imageView.image.size.height;
        _stamp.xProportion = self.center.x / self.superview.bounds.size.width;
        _stamp.yProportion = self.center.y / self.superview.bounds.size.height;
        
        [[SRMStampStore sharedStore] saveChanges];
    }
}

- (IBAction)deleteStamp:(id)sender
{
    SRMMonthBoardView *board = (SRMMonthBoardView *)[[self superview] superview];
    [board deleteStamp:_stamp];
    [self removeFromSuperview];
}

@end
