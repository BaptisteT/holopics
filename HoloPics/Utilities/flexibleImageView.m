//
//  flexibleImageView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "flexibleImageView.h"

@interface flexibleImageView()

@property (nonatomic, strong) IBOutlet UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) IBOutlet UIRotationGestureRecognizer *rotationRecognizer;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *panningRecognizer;
@property (nonatomic, strong) NSMutableSet *activeRecognizers;
@property(nonatomic) CGAffineTransform referenceTransform;

@end

@implementation flexibleImageView

- (id)initWithImage:(UIImage *)image
{
    if (self = [super initWithImage:image])
    {
        // Add gesture recognisers
        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        self.rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        self.panningRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanningGesture:)];
        [self addGestureRecognizer:self.pinchRecognizer];
        [self addGestureRecognizer:self.rotationRecognizer];
        [self addGestureRecognizer:self.panningRecognizer];
        self.pinchRecognizer.delegate = self;
        self.rotationRecognizer.delegate = self;
        self.panningRecognizer.delegate = self;
        
        self.activeRecognizers = [NSMutableSet set];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (IBAction)handleGesture:(UIGestureRecognizer *)recognizer
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
            for (UIGestureRecognizer *recognizer in self.activeRecognizers)
                transform = [self applyRecognizer:recognizer toTransform:transform];
            self.transform = transform;
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)handlePanningGesture:(UIPanGestureRecognizer *)recognizer
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

@end
