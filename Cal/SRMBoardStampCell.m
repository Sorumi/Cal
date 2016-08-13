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

@end

@implementation SRMBoardStampCell

- (void)awakeFromNib {
    // Initialization code
    
    UIPanGestureRecognizer *panStamp = [[UIPanGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(moveStamp:)];
    [self addGestureRecognizer:panStamp];
    
    self.deleteButton.layer.cornerRadius = 6;
    self.deleteButton.hidden = YES;
}

- (void)setEditMode:(BOOL)isEditMode
{
    self.deleteButton.hidden = !isEditMode;
//    if (isEditMode) {
//        if ([[[self layer] sublayers] objectAtIndex:0]) {
//            self.layer.sublayers = nil;
//        }
////
//        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
//        [shapeLayer setBounds:self.bounds];
//        [shapeLayer setPosition:self.center];
////        [shapeLayer setFillColor:[UIColor colorWithWhite:0.3 alpha:1].CGColor];
//        [shapeLayer setStrokeColor:[UIColor colorWithWhite:0.3 alpha:1].CGColor];
//        [shapeLayer setLineWidth:0.5f];
//        [shapeLayer setLineJoin:kCALineJoinRound];
//        [shapeLayer setLineDashPattern:@[@(2), @(3)]];
//        
//        CGMutablePathRef path = CGPathCreateMutable();
//        
//        CGFloat width = self.frame.size.width;
//        CGFloat height = self.frame.size.height;
//        
//        CGPathMoveToPoint(path, NULL, 6, 6);
//        CGPathAddLineToPoint(path, NULL, width-6, 6);
//        CGPathAddLineToPoint(path, NULL, width-6, height-6);
//        CGPathAddLineToPoint(path, NULL, 6, height-6);
//        CGPathAddLineToPoint(path, NULL, 6, 6);
//            
//        [shapeLayer setPath:path];
//        
//        CGPathRelease(path);
//        
//        [[self layer] addSublayer:shapeLayer];
//    } else {
////        self.layer.sublayers = nil;
//    }
}

- (void)setStamp:(SRMStamp *)stamp
{
    _stamp = stamp;
    self.imageView.image = [[SRMStampStore sharedStore] stampForName:stamp.name];
}

- (void)moveStamp:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {

//        UICollectionView *collectionView = (UICollectionView *)[self superview];
//        [collectionView selectItemAtIndexPath:[collectionView indexPathForCell:self] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture translationInView:self];
        
        CGFloat x = self.center.x + point.x;
        CGFloat y = self.center.y + point.y;
        
        self.center = CGPointMake(x, y);
        [gesture setTranslation:CGPointZero inView:self];
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
//        NSLog(@"%f", self.superview.bounds.size.width);
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
