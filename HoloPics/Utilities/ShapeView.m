//
//  ShapeView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ShapeView.h"
#import "ImageUtilities.h"
#import "GeneralUtilities.h"
#import "Constants.h"
#import "ShapeOptionOverlayView.h"


@interface ShapeView()

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panningRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *oneTapRecognizer;
@property (nonatomic, strong) NSMutableSet *activeRecognizers;
@property(nonatomic) CGAffineTransform referenceTransform;
@property (strong, nonatomic) ShapeOptionOverlayView *shapeOptionOverlayView;


@end

@implementation ShapeView

- (id)initWithImage:(UIImage *)image
              frame:(CGRect) frame
            andPath:(UIBezierPath *)path
{
    self.attachedImage = [ImageUtilities imageWithImage:image scaledToSize:frame.size];
    self.frame = frame;
    return [self initShapeViewWithPath:path];
}

- (id)initShapeViewWithPath:(UIBezierPath *)path
{
    if (self = [super initWithImage:self.attachedImage])
    {
        // Add gesture recognisers
        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        self.rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        self.panningRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanningGesture:)];
        self.oneTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapGesture:)];
        
        [self addGestureRecognizer:self.pinchRecognizer];
        [self addGestureRecognizer:self.rotationRecognizer];
        [self addGestureRecognizer:self.panningRecognizer];
        [self addGestureRecognizer:self.oneTapRecognizer];
        
        self.pinchRecognizer.delegate = self;
        self.rotationRecognizer.delegate = self;
        self.panningRecognizer.delegate = self;
        self.oneTapRecognizer.delegate = self;
        self.oneTapRecognizer.numberOfTapsRequired = 1;
        self.activeRecognizers = [NSMutableSet set];
        
        // User interaction
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.exclusiveTouch = YES;
        
        // Path
        self.imagePath = path;
        
        // Init anchor point
        self.anchorPoint = CGPointMake(path.bounds.origin.x + path.bounds.size.width / 2, path.bounds.origin.y + path.bounds.size.height / 2);
        [GeneralUtilities setAnchorPoint:CGPointMake(self.anchorPoint.x / self.frame.size.width, self.anchorPoint.y/self.frame.size.height) forView:self];
        
        // Init option overlay
        [self initAndDisplayShapeOptionOverlay];
    }
    return self;
}


// -------------------
// Gesture handling
// ------------------

- (void)handleGesture:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (self.activeRecognizers.count == 0)
                self.referenceTransform = self.transform;
            [self.activeRecognizers addObject:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            self.referenceTransform = [self applyRecognizer:recognizer toTransform:self.referenceTransform];
            [self.activeRecognizers removeObject:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGAffineTransform transform = self.referenceTransform;
            CGAffineTransform scaleTransform = self.referenceTransform;
            for (UIGestureRecognizer *recognizer in self.activeRecognizers) {
                transform = [self applyRecognizer:recognizer toTransform:transform];
                if ([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    scaleTransform = [self applyRecognizer:recognizer toTransform:scaleTransform];
                }
            }
            self.transform = transform;
            
            // Revert transform for overlaybutton
            [self.shapeOptionOverlayView revertTransformForOverlayButtons:transform
                                                           scaleTransform:scaleTransform];
            break;
        }
            
        default:
            break;
    }
}

- (void)handlePanningGesture:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint initialCenter;
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        initialCenter = recognizer.view.center;
    }
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    recognizer.view.center = CGPointMake(initialCenter.x + translation.x,
                                     initialCenter.y + translation.y);
}

- (void)oneTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.shapeOptionOverlayView.isHidden) {
        [self.shapeViewDelegate removeAllShapeOverlay];
        [self.shapeOptionOverlayView setHidden:NO];
    } else {
        [self.shapeOptionOverlayView setHidden:YES];
    }
}

- (CGAffineTransform)applyRecognizer:(UIGestureRecognizer *)recognizer toTransform:(CGAffineTransform)transform
{
    if ([recognizer respondsToSelector:@selector(rotation)]) {
        return CGAffineTransformRotate(transform, [(UIRotationGestureRecognizer *)recognizer rotation]);
    } else if ([recognizer respondsToSelector:@selector(scale)]) {
        CGFloat scale = [(UIPinchGestureRecognizer *)recognizer scale];
        return CGAffineTransformScale(transform, scale, scale);
    }
    else
        return transform;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // if the gesture recognizers's view isn't one of our views, don't allow simultaneous recognition
    if (gestureRecognizer.view != self && otherGestureRecognizer.view != self)
        return NO;
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    if (![gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return NO;
    if (![otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && ![otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return NO;
    return YES;
}


// ------------
// Utilities
// ------------

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.shapeOptionOverlayView.isHidden) {
        return [self.imagePath containsPoint:point];
    } else {
        return CGRectContainsPoint(self.shapeOptionOverlayView.frame, point);
    }
}

- (void)initAndDisplayShapeOptionOverlay
{
    self.shapeOptionOverlayView = [[ShapeOptionOverlayView alloc] initWithShapeView:self];
    [self addSubview:self.shapeOptionOverlayView];
}

- (void)hideOptionOverlayView
{
    [self.shapeOptionOverlayView setHidden:YES];
}


@end
