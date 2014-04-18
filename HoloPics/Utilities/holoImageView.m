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

@interface holoImageView()

@property (strong, nonatomic) UIBezierPath *path;

@end

@implementation holoImageView {
    CGPoint pts[5];
    CGPoint initialPoint;
    int ctr;
    BOOL isPathBuilt;
}


// init
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        self.path = [UIBezierPath bezierPath];
        [self.path setLineWidth:2.0];
        self.globalPath = [UIBezierPath bezierPath];
        self.isOutsideImageVisible = NO;
        self.isInsideImageVisible = NO;
        isPathBuilt = NO;
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        self.path = [UIBezierPath bezierPath];
        [self.path setLineWidth:2.0];
        self.globalPath = [UIBezierPath bezierPath];
        self.isOutsideImageVisible = NO;
        self.isInsideImageVisible = NO;
        isPathBuilt = NO;
    }
    return self;
}

// ----------------------------------------------------------
// Drawing
// ----------------------------------------------------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    initialPoint = [touch locationInView:self];
    pts[0] = initialPoint;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    // We deal with continuous movement only when there is no path yet
    if (!isPathBuilt) {
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
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(ctr == 0) { // non continuous mvt
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
                    if(self.isOutsideImageVisible) {
                        if (self.outsideImage) {
                            [self setImage:self.outsideImage];
                        } else {
                            [self.holoImageViewDelegate takePictureAndDisplay:kDisplayOutside];
                        }
                    } else {
                        [self setImage:nil];
                        [self drawBitmapAlongPath:self.globalPath];
                    }
                } else {
                    // take inside picture
                    [self.holoImageViewDelegate takePictureAndDisplay:kDisplayInside];
                }
            } else {
                if(self.isOutsideImageVisible) {
                    // remove outside
                    self.isOutsideImageVisible = NO;
                    // if inside image, make it visible
                    if(self.isInsideImageVisible) {
                        if(self.insideImage) {
                            [self setImage:self.insideImage];
                        } else {
                            [self.holoImageViewDelegate takePictureAndDisplay:kDisplayInside];
                        }
                    } else {
                        [self setImage:nil];
                        [self drawBitmapAlongPath:self.globalPath];
                    }
                } else {
                    // take oustside picture
                    [self.holoImageViewDelegate takePictureAndDisplay:kDisplayOutside];
                }
            }
        }
    } else if(!self.path.empty) { // 1st continuous mvt: draw path
        // Draw path
        [self.path addLineToPoint:initialPoint];
        [self setNeedsDisplay];
        [self drawBitmapAlongPath:self.path];
        [self.path removeAllPoints];
        ctr = 0;
        [self.globalPath addLineToPoint:initialPoint];
        isPathBuilt = YES;
        if (self.fullImage) {
            self.isInsideImageVisible = YES;
            self.isOutsideImageVisible = YES;
//            UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 0);
//            [self.globalPath addClip];
//            [self.image drawAtPoint:CGPointZero];
//            self.insideImage = UIGraphicsGetImageFromCurrentImageContext();
//            
            self.insideImage = [ImageUtilities drawFromImage:self.image insidePath:self.globalPath];
            self.outsideImage = [ImageUtilities drawFromImage:self.image outsidePath:self.globalPath];
//            // Outside the path image
//            // Create an image context containing the original UIImage.
//            UIGraphicsBeginImageContext(self.image.size);
//            [self.image drawAtPoint:CGPointZero];
//            
//            // Clip to the bezier path and clear that portion of the image.
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextAddPath(context,self.globalPath.CGPath);
//            CGContextClip(context);
//            CGContextClearRect(context,CGRectMake(0,0,self.image.size.width,self.image.size.height));
//            
//            // Build a new UIImage from the image context.
//            self.outsideImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
        }
        // If full screen picture, divide it
//        if (self.fullImage) {
//            // Inside the path image
//            self.insideImage = [ImageUtilities drawFromImage:self.fullImage insidePath:self.globalPath];
//            
//            // Outside the path image
//            self.outsideImage = [ImageUtilities drawFromImage:self.fullImage outsidePath:self.globalPath withSize:self.bounds.size];
//            
//            self.isInsideImageVisible = YES;
//            self.isOutsideImageVisible = YES;
//        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
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

// todo delete
- (void)drawBitmap2
{
    UIGraphicsBeginImageContext(self.frame.size);
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [[UIColor blackColor] setFill];
    [self.globalPath fill];
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
//

@end


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    self.mouseSwiped = NO;
//    UITouch *touch = [touches anyObject];
//    self.lastPoint = [touch locationInView:self];
//    self.pathPoints = [NSMutableArray arrayWithObject:[NSValue valueWithCGPoint:self.lastPoint]];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    self.mouseSwiped = YES;
//    UITouch *touch = [touches anyObject];
//    CGPoint currentPoint = [touch locationInView:self];
//    [self.pathPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
//    
//    UIGraphicsBeginImageContext(self.frame.size);
//    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastPoint.x, self.lastPoint.y);
//    
//    // design
//    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2 );// todo
//    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0); //todo
//    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
//    
//    CGContextStrokePath(UIGraphicsGetCurrentContext());
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    [self setAlpha:1];
//    UIGraphicsEndImageContext();
//    
//    self.lastPoint = currentPoint;
//    NSLog(@"a");
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UIGraphicsBeginImageContext(self.frame.size);
//    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//}
//
//
//@end
