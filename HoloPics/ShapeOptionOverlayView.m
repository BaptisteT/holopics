//
//  ShapeOptionOverlayView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/22/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ShapeOptionOverlayView.h"
#import "Constants.h"
#import "ImageUtilities.h"

@interface ShapeOptionOverlayView ()

@property (weak, nonatomic) ShapeView *shapeView; // owner
@property (weak, nonatomic) IBOutlet UIButton *BinButton;
@property (weak, nonatomic) IBOutlet UIButton *transparencyButton;


@end


@implementation ShapeOptionOverlayView

- (id)initWithShapeView:(ShapeView *)shapeView
{
    NSString *xibName = @"ShapeOptionOverlay";
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
    self = [nibViews objectAtIndex: 0];
    
    self.shapeView = shapeView;
    
    self.autoresizesSubviews = NO;self.autoresizingMask = UIViewAutoresizingNone;
    CGRect pathFrame = shapeView.imagePath.bounds;
    CGFloat height, width;
    if (pathFrame.size.height < kShapeOptionOverlayMinLayerSize) {
        height = kShapeOptionOverlayMinLayerSize + kShapeOptionOverlayButtonSize;
    } else {
        height = pathFrame.size.height + kShapeOptionOverlayButtonSize;
    }
    if (pathFrame.size.width < kShapeOptionOverlayMinLayerSize) {
        width = kShapeOptionOverlayMinLayerSize + kShapeOptionOverlayButtonSize;
    } else {
        width = pathFrame.size.width + kShapeOptionOverlayButtonSize;
    }
    CGRect longPressOverlayFrame = CGRectMake(pathFrame.origin.x - (width - pathFrame.size.width) /2,
                                              pathFrame.origin.y - (height - pathFrame.size.height) /2,
                                              width,
                                              height);
    CGRect borderLayerFrame = CGRectMake(kShapeOptionOverlayButtonSize/2, kShapeOptionOverlayButtonSize/2,longPressOverlayFrame.size.width - kShapeOptionOverlayButtonSize, longPressOverlayFrame.size.height - kShapeOptionOverlayButtonSize);
    
    self.frame = longPressOverlayFrame;
    [ImageUtilities outerGlow:self.BinButton];
    [ImageUtilities outerGlow:self.resizeButton];
    [ImageUtilities outerGlow:self.transparencyButton];
    
    CALayer *fill = [CALayer layer];
    fill.backgroundColor = [UIColor whiteColor].CGColor;
    fill.opacity = 0.1f;
    fill.frame = borderLayerFrame;
    
    [self.layer addSublayer:fill];
    
    return self;
}

-(void)revertTransformForOverlayButtons:(CGAffineTransform)transform scaleTransform:(CGAffineTransform)scaleTransform
{
    self.BinButton.transform = CGAffineTransformInvert(transform);
    self.resizeButton.transform = CGAffineTransformInvert(scaleTransform);
    self.transparencyButton.transform = CGAffineTransformInvert(transform);
}

// --------------------------------
// Shape Options Overlay Buttons
// -------------------------------
- (IBAction)transparencyButtonClicked:(id)sender {
    CGFloat newAlpha = (self.shapeView.alpha > 0.3) ? self.shapeView.alpha - 0.2 : 1;
    [self.shapeView setAlpha:newAlpha];
}

- (IBAction)binButtonClicked:(id)sender {
    [self.shapeView.shapeViewDelegate deleteView:self.shapeView];
}

- (IBAction)resizeButtonPanned:(UIPanGestureRecognizer *)recognizer {
    static CGFloat initialDistance;
    static CGPoint initialPoint;
    CGAffineTransform scaleTransform = self.shapeView.transform;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        initialPoint = [recognizer locationInView:self.superview];
        initialDistance = sqrt(pow(self.shapeView.anchorPoint.x - initialPoint.x,2) + pow(self.shapeView.anchorPoint.y - initialPoint.y,2));
    } else {
        CGPoint newPoint = [recognizer locationInView:self.superview];
        CGFloat newDistance = sqrt(pow(self.shapeView.anchorPoint.x - newPoint.x,2) + pow(self.shapeView.anchorPoint.y - newPoint.y,2));
        CGFloat scale = newDistance / initialDistance;
        scaleTransform = CGAffineTransformScale(scaleTransform, scale, scale);
        
        CGFloat oppositeDistance = sqrt(pow(initialPoint.x - newPoint.x,2) + pow(initialPoint.y - newPoint.y,2));
        CGFloat angle = acosf((pow(initialDistance,2) + pow(newDistance,2) - pow(oppositeDistance,2))/(2*initialDistance*newDistance));
        if(newPoint.y < initialPoint.y) {
            angle = - angle;
        }
        CGAffineTransform transform = CGAffineTransformRotate(scaleTransform, angle);
        
        self.shapeView.transform = transform;
        
        // Revert transform for overlaybutton
        [self revertTransformForOverlayButtons:transform scaleTransform:scaleTransform];
    }
}



@end
