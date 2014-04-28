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


@interface holoImageView()

@property (strong, nonatomic) UIBezierPath *path;

@end

@implementation holoImageView {
    CGPoint pts[5];
    CGPoint initialPoint;
    int ctr;
    BOOL isContinuousMovement;
    BOOL isLongTouch;
    BOOL isPathBuilt;
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
// Touch detection
// ----------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    isContinuousMovement = NO;
    isLongTouch = NO;
    UITouch *touch = [touches anyObject];
    initialPoint = [touch locationInView:self];
    pts[0] = initialPoint;
    
    // Start timer for long touch gesture detection
    [self performSelector:@selector(fireLongPress:)
               withObject:(id)touches
               afterDelay:kLongPressTimeThreshold];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    
    if([PathUtility distanceBetweenPoint:initialPoint andPoint:p] > kContinuousMovementDistanceThreshold) {
        isContinuousMovement = true;
        // Cancel long touch timer
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    // Draw path only when we have a full picture
    if(self.fullImage) {
        // Remove previous path if any
        if (isPathBuilt) {
            [self setImage:self.fullImage];
            [self.globalPath removeAllPoints];
            isPathBuilt = NO;
        }
        // Build and draw path
        [self buildPathAlongContinuousTouch:p];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Cancel long touch timer
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if(isLongTouch) { // long touch action in fireLongPress
        return;
    }
    
    if(!isContinuousMovement) {
        if(self.globalPath.empty) {
            if(!self.fullImage) {
                // take full picture and display it
                [self.holoImageViewDelegate takePictureAndDisplay:kDisplayFull];
            } else {
                self.fullImage = nil;
                [self setImage:nil];
            }
        } else {
            UITouch *touch = [touches anyObject];
            CGPoint point = [touch locationInView:self];
            BOOL isHit = [self.globalPath containsPoint:point];
            
            if(isHit) {
                if(self.isInsideImageVisible) {
                    // Remove inside
                    self.isInsideImageVisible = NO;
                    [self setImage:self.outsideImage];
                    self.isOutsideImageVisible = YES;
                    self.fullImage = nil;
                } else {
                    // take inside picture
                    [self.holoImageViewDelegate takePictureAndDisplay:kDisplayInside];
                }
            } else {
                if(self.isOutsideImageVisible) {
                    // remove outside
                    self.isOutsideImageVisible = NO;
                    [self setImage:self.insideImage];
                    self.isInsideImageVisible = YES;
                    self.fullImage = nil;
                } else {
                    // take oustside picture
                    [self.holoImageViewDelegate takePictureAndDisplay:kDisplayOutside];
                }
            }
        }
    } else if(!self.path.empty) { // continuous mvt: draw path
        // End path
        [PathUtility closePath:self.path withInitialPoint:initialPoint inRect:self.bounds.size];
        
        if([PathUtility isMinimalSizePath:self.path]) {
            // Draw path
            [self setNeedsDisplay];
            [self drawBitmapAlongPath:self.path];
            
            isPathBuilt = YES;
            [PathUtility closePath:self.globalPath withInitialPoint:initialPoint inRect:self.bounds.size];

            if (self.fullImage) {
                self.isInsideImageVisible = YES;
                self.isOutsideImageVisible = YES;
                self.insideImage = [ImageUtilities drawFromImage:self.fullImage insidePath:self.globalPath];
                self.outsideImage = [ImageUtilities drawFromImage:self.fullImage outsidePath:self.globalPath];
            }
        } else {
            // Cancel path
            isPathBuilt = NO;
            [self.globalPath removeAllPoints];
            [self setImage:self.fullImage];
        }
        [self.path removeAllPoints];
        ctr = 0;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

// ----------------------------------------------------------
// Touch action
// ----------------------------------------------------------

- (void)fireLongPress:(NSSet *)touches
{
    isLongTouch = YES;
    if(self.globalPath.empty) {
        [self.holoImageViewDelegate letUserImportPhotoAndDisplay:kDisplayFull];
    } else {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        BOOL isHit = [self.globalPath containsPoint:point];
        
        if(isHit) {
            [self.holoImageViewDelegate letUserImportPhotoAndDisplay:kDisplayInside];
        } else {
            [self.holoImageViewDelegate letUserImportPhotoAndDisplay:kDisplayOutside];
        }
    }
}


// --------------------------------
// Utilities
// --------------------------------

- (void)buildPathAlongContinuousTouch:(CGPoint)p
{
    ctr++;
    pts[ctr] = p;
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
    [self drawBitmapAlongPath:self.path];
}

- (void)drawBitmapAlongPath:(UIBezierPath *)path
{
    UIGraphicsBeginImageContext(self.frame.size);
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [[UIColor blackColor] setStroke];
    [path stroke];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)clearPathAndPictures
{
    self.isInsideImageVisible = NO;
    self.isOutsideImageVisible = NO;
    self.fullImage = nil;
    self.insideImage = nil;
    self.outsideImage = nil;
    [self.globalPath removeAllPoints];
    [self.path removeAllPoints];
    [self setImage:nil];
    isPathBuilt = NO;
}

- (void)initHoloImageView
{
    [self setMultipleTouchEnabled:NO];
    self.path = [UIBezierPath bezierPath];
    [self.path setLineWidth:2.0];
    self.globalPath = [UIBezierPath bezierPath];
    self.isOutsideImageVisible = NO;
    self.isInsideImageVisible = NO;
    isPathBuilt = NO;
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
