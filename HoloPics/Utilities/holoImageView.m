//
//  holoImageView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "holoImageView.h"
#import "Constants.h"
#import "ImageUtilities.h"
#import "GeneralUtilities.h"
#import "PathUtility.h"
#import "MagnifierView.h"


@interface holoImageView()

@property (strong, nonatomic) UIBezierPath *path;
@property (strong, nonatomic) MagnifierView *zoomImage;
@property (nonatomic, strong) UIPanGestureRecognizer *panningRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *oneTapRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;

@end

@implementation holoImageView {
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
        [self initHoloImageView];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initHoloImageView];
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
        ctr = 0;
        initialPoint = currentPoint;
        pts[0] = initialPoint;
        if(self.fullImage) {
            if (self.zoomImage == nil) {
                self.zoomImage = [[MagnifierView alloc] init];
                self.zoomImage.viewToMagnify = self;
            }
            [self.zoomImage setCenterPoint:initialPoint];
            [self.zoomImage setNeedsDisplay];
            [self.superview addSubview:self.zoomImage];
        }
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
            [self.holoImageViewDelegate createFlexibleSubView];
        }
        
        [self.globalPath removeAllPoints];
        [self.path removeAllPoints];
        [self setImage:self.fullImage];
        ctr = 0;
        
        [self.zoomImage removeFromSuperview];
    }
}

// One tap
- (void)handleOneTapGesture:(UITapGestureRecognizer *)recognizer
{
    if(!self.fullImage) {
        // take full picture and display it
        [self.holoImageViewDelegate takePictureAndDisplay];
        [self addGestureRecognizer:self.pinchRecognizer];
    } else {
        [self clearPathAndPictures];
        [self.holoImageViewDelegate hideSaveandUnhideFlipButton];
        [self removeGestureRecognizer:self.pinchRecognizer];
    }
}

// Long touch
- (void)handleLongPressGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.holoImageViewDelegate letUserImportPhotoAndDisplay];
        [self addGestureRecognizer:self.pinchRecognizer];
    }
}

// Pinch
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recogniser
{
    // fo nothing
}


// --------------------------------
// Gesture Recogniser protocol
// --------------------------------

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recogniser
{
    if ([recogniser isKindOfClass:[UIPanGestureRecognizer class]]) {
        return (self.fullImage !=nil);
    } else {
        return YES;
    }
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
    self.fullImage = nil;
    [self.globalPath removeAllPoints];
    [self.path removeAllPoints];
    [self setImage:nil];
}

- (void)initHoloImageView
{
    [self setMultipleTouchEnabled:YES];
    self.exclusiveTouch = YES;
    self.path = [UIBezierPath bezierPath];
    [self.path setLineWidth:2.0];
    self.globalPath = [UIBezierPath bezierPath];
    [self setBackgroundColor:[UIColor clearColor]];
    
    // Alloc and add gesture recognisers
    self.panningRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanningGesture:)];
    self.oneTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneTapGesture:)];
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    
    [self addGestureRecognizer:self.panningRecognizer];
    [self addGestureRecognizer:self.oneTapRecognizer];
    [self addGestureRecognizer:self.longPressRecognizer];
    
    self.panningRecognizer.delegate = self;
    self.oneTapRecognizer.delegate = self;
    self.longPressRecognizer.delegate = self;
    self.pinchRecognizer.delegate = self;
    
    self.oneTapRecognizer.numberOfTapsRequired = 1;
    self.longPressRecognizer.minimumPressDuration = kLongPressTimeThreshold;
}


@end
