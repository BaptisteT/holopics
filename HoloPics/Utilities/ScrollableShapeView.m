//
//  ScrollableShapeView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/16/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ScrollableShapeView.h"
#import "ImageUtilities.h"
#import "Constants.h"
#import "PathUtility.h"


@interface ScrollableShapeView()

@property (strong, nonatomic) UIImage *shapeImage;
@property (nonatomic, strong) UIPanGestureRecognizer *panningRecognizer;
@property (strong, nonatomic) ShapeView *controlledShapeView;


@end

@implementation ScrollableShapeView

- (id)initWithShapeInfo:(ShapeInfo *)shapeInfo
{
    self = [super init];
    if (self) {
        self.shapeInfo = shapeInfo;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.panningRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanningGesture:)];
        [self addGestureRecognizer:self.panningRecognizer];
        self.panningRecognizer.delegate = self;
        
        // Create Image
        self.shapeImage = [ImageUtilities getImageAtRelativePath:self.shapeInfo.relativeImagePath];
        self.image = [ImageUtilities imageWithImage:self.shapeImage scaledToSize:[[UIScreen mainScreen] bounds].size];
    }
    return self;
}


- (void)setImage:(UIImage *)image
{
    // crop image to show only path bounds
    CGRect pathSquareBounds = [PathUtility getSquareBoundsOfPath:self.shapeInfo.bezierPath];
    
    CGImageRef subImage = CGImageCreateWithImageInRect ([image CGImage],pathSquareBounds);
    [super setImage:[UIImage imageWithCGImage:subImage]];
}

- (void)incremenentIndexAndFrameOf:(int)position
{
    self.shapeInfo.index = [NSNumber numberWithInteger:[self.shapeInfo.index integerValue] + position];

    self.frame = CGRectMake([self.shapeInfo.index integerValue] * kScrollableViewHeight + kScrollableViewInitialOffset, 0, kScrollableViewHeight, kScrollableViewHeight);
}

- (void)handlePanningGesture:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint initialCenter;
    CGFloat newCenter = 0;
    CGPoint newCenterPoint, velocity;
    static BOOL isSlide = FALSE;

    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        velocity = [recognizer velocityInView:self];
        if (velocity.y > kMinDeleteVelocity && velocity.y > 2 * fabs(velocity.x)) {
            isSlide = FALSE;
            [self.scrollableShapeViewDelegate deleteShapeFromScrollView:self];
            return;
        } else if (- velocity.y < fabs(velocity.x) ) {
            isSlide = TRUE;
            initialCenter = ((UIScrollView *)self.superview).contentOffset;
        } else {
            isSlide = FALSE;
            initialCenter = self.center;
        }
    }
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    if (isSlide) {
        newCenter = MIN( MAX(((UIScrollView *)self.superview).contentSize.width - kScreenWidth,0),MAX(initialCenter.x - translation.x, 0));
        ((UIScrollView *)self.superview).contentOffset = CGPointMake(newCenter,0);
    } else {
        newCenterPoint = CGPointMake(initialCenter.x + translation.x,initialCenter.y + translation.y);
        self.center = newCenterPoint;
        if (initialCenter.y + translation.y < 0) {
            self.center = initialCenter;
            if(!self.controlledShapeView) {
                self.controlledShapeView = [self.scrollableShapeViewDelegate insertNewShapeViewWithImage:self.shapeImage andPath:self.shapeInfo.bezierPath];
            }
        } else {
            if (self.controlledShapeView) {
                [self.scrollableShapeViewDelegate removeShape:self.controlledShapeView];
                self.controlledShapeView = nil;
            }
        }
        if(self.controlledShapeView) {
            [self.scrollableShapeViewDelegate setShapeCenter:self.controlledShapeView ToPoint:newCenterPoint];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded){
        if (isSlide) {
            velocity = [recognizer velocityInView:self];
            CGFloat finalCenter = MIN( MAX(((UIScrollView *)self.superview).contentSize.width - kScreenWidth,0),MAX(newCenter - velocity.x / 5, 0));
            NSTimeInterval duration = MIN(0.5,abs(velocity.x/500));
            [UIView animateWithDuration:duration delay:0
                                options:(UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState)
                             animations:^ {
                                 ((UIScrollView *)self.superview).contentOffset = CGPointMake(finalCenter,0);
                             }
                             completion:NULL];
        } else {
            self.center = initialCenter;
            self.controlledShapeView = nil;
        }
    }
}


@end
