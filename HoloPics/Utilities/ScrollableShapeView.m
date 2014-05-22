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
        self.shapeImage = [ImageUtilities imageWithImage:[ImageUtilities getImageAtRelativePath:self.shapeInfo.relativeImagePath] scaledToSize:[[UIScreen mainScreen] bounds].size];
        self.image = self.shapeImage;
    }
    return self;
}


- (void)setImage:(UIImage *)image
{
    // crop image to show only path bounds
    CGFloat side, xOrigin, yOrigin;
    CGRect pathBounds = self.shapeInfo.bezierPath.bounds;
    if (pathBounds.size.height > pathBounds.size.width) {
        side = pathBounds.size.height;
        xOrigin = MAX(0,pathBounds.origin.x - (side - pathBounds.size.width) / 2);
        yOrigin = pathBounds.origin.y;
    } else {
        side = pathBounds.size.width;
        xOrigin = pathBounds.origin.x;
        yOrigin = MAX(0,pathBounds.origin.y - (side - pathBounds.size.height) / 2);
    }

    CGRect newRect = CGRectMake(xOrigin, yOrigin, side, side);
    
    CGImageRef subImage = CGImageCreateWithImageInRect ([image CGImage],newRect);
    [super setImage:[UIImage imageWithCGImage:subImage]];
}

- (void)incremenentIndexAndFrameOf:(int)position
{
    self.shapeInfo.index = [NSNumber numberWithInt:[self.shapeInfo.index intValue] + position];
    
    self.frame = CGRectMake([self.shapeInfo.index floatValue] * kScrollableViewHeight + kScrollableViewInitialOffset, 0, kScrollableViewHeight, kScrollableViewHeight);
}

- (void)handlePanningGesture:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint initialCenter;
    static BOOL isSlide = FALSE;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint velocity = [recognizer velocityInView:self];
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
        CGFloat newCenter = MIN( MAX(((UIScrollView *)self.superview).contentSize.width - kScreenWidth,0),MAX(initialCenter.x - translation.x, 0));
        ((UIScrollView *)self.superview).contentOffset = CGPointMake(newCenter,0);
    } else {
        CGPoint newCenterPoint = CGPointMake(initialCenter.x + translation.x,initialCenter.y + translation.y);
        self.center = newCenterPoint;
        if (initialCenter.y + translation.y < 0) {
            self.center = initialCenter;
            if(!self.controlledShapeView) {
                self.controlledShapeView = [self.scrollableShapeViewDelegate createNewShapeViewWithImage:self.shapeImage andPath:self.shapeInfo.bezierPath];
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
        if (!isSlide) {
            self.center = initialCenter;
            self.controlledShapeView = nil;
        }
    }
}


@end
