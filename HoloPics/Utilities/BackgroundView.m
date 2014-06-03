//
//  BackgroundView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "BackgroundView.h"
#import "Constants.h"
#import "ImageUtilities.h"
#import "GeneralUtilities.h"
#import "PathUtility.h"
#import "MagnifierView.h"


@interface BackgroundView()

@property (strong, nonatomic) UIBezierPath *path;
@property (strong, nonatomic) MagnifierView *zoomImage;
@property (nonatomic, strong) UIPanGestureRecognizer *panningRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *oneTapRecognizer;

@end

@implementation BackgroundView {
    // One finger
    CGPoint pts[5];
    CGPoint initialPoint;
    int ctr;
    BOOL isContinuousMovement;
    BOOL isLongTouch;
}


// init
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initBackgroundView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBackgroundView];
    }
    return self;
}


// ----------------------------------------------------------
// Handle Gestures
// ----------------------------------------------------------

// Panning
- (void)handlePanningGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint currentPoint = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Hide shapes
        [self.backgroundViewDelegate hideShapesDuringDrawing];
        ctr = 0;
        initialPoint = currentPoint;
        pts[0] = initialPoint;
        if (self.zoomImage == nil) {
            self.zoomImage = [[MagnifierView alloc] init];
            self.zoomImage.center = CGPointMake(self.superview.frame.size.width - 60 ,60);
            self.zoomImage.viewToMagnify = self;
        }
        [self.zoomImage setCenterPoint:initialPoint];
        [self.zoomImage setNeedsDisplay];
        [self.superview addSubview:self.zoomImage];
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self buildPathAlongContinuousTouch:currentPoint];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [PathUtility closePath:self.path withInitialPoint:initialPoint inRect:self.bounds.size];
        
        if([PathUtility isMinimalSizePath:self.path]) {
            // Draw path
            [self setNeedsDisplay];
            [ImageUtilities drawPath:self.path inImageView:self];
            
            [PathUtility closePath:self.globalPath withInitialPoint:initialPoint inRect:self.bounds.size];
            
            // Create a flexible subview with the image inside the path
            [self.backgroundViewDelegate createShapeWithImage:self.originalImage andPath:self.globalPath];
        }
        
        [self.globalPath removeAllPoints];
        [self.path removeAllPoints];
        [self setImage:self.originalImage];
        ctr = 0;
        
        [self.zoomImage removeFromSuperview];
        
        // display shapes again
        [self.backgroundViewDelegate displayShapesAfterDrawing];
    }
}

// One tap
- (void)handleOneTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self.backgroundViewDelegate removeAllShapeOverlay];
}



// --------------------------------
// Utilities
// --------------------------------

- (void)buildPathAlongContinuousTouch:(CGPoint)p
{
    ctr++;
    pts[ctr] = p;
    
    [self.zoomImage setCenterPoint:p];
    [self.zoomImage setNeedsDisplay];
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
        [self.path moveToPoint:pts[0]];
        [self.path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        
        // Init global path if empty
        if (self.globalPath.empty){
            [self.globalPath moveToPoint:initialPoint];
        }
        [self.globalPath addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
    [ImageUtilities drawPath:self.path inImageView:self];
}

- (void)clearPathAndPictures
{
    self.originalImage = [UIImage imageNamed:@"create_tuto"];
    [self.globalPath removeAllPoints];
    [self.path removeAllPoints];
    [self setImage:self.originalImage];
}

- (void)initBackgroundView
{
    [self setMultipleTouchEnabled:YES];
    self.exclusiveTouch = YES;
//    self.contentMode = UIViewContentModeScaleAspectFit;
    [self setBackgroundColor:[UIColor clearColor]];
    self.path = [UIBezierPath bezierPath];
    [self.path setLineWidth:2.0];
    self.globalPath = [UIBezierPath bezierPath];
    
    self.originalImage = [UIImage imageNamed:@"create_tuto"];
    [self setImage:self.originalImage];
    
    // Alloc and add gesture recognisers
    self.panningRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanningGesture:)];
    self.oneTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneTapGesture:)];
    
    [self addGestureRecognizer:self.panningRecognizer];
    [self addGestureRecognizer:self.oneTapRecognizer];
    
    self.panningRecognizer.delegate = self;
    self.panningRecognizer.maximumNumberOfTouches = 1;
    self.oneTapRecognizer.delegate = self;
    self.oneTapRecognizer.numberOfTapsRequired = 1;
}


// -----------------------------
// Gesture recogniser delegate
// -----------------------------


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        // Don't pan if we are on the scroll view
        return [self.backgroundViewDelegate isShapeScrollableViewHidden] || [gestureRecognizer locationInView:self].y < self.frame.size.height - kScrollableViewHeight;
    }
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // if the gesture recognizers's view isn't one of our views, don't allow simultaneous recognition
    if (gestureRecognizer.view != self || otherGestureRecognizer.view != self)
        return NO;
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

@end
