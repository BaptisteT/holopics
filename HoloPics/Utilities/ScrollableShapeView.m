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

@property (strong, nonatomic) ShapeInfo *shapeInfo;
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
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.panningRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanningGesture:)];
        [self addGestureRecognizer:self.panningRecognizer];
        self.panningRecognizer.delegate = self;
        
        // Create Image
        self.shapeImage = [ImageUtilities getImageAtRelativePath:self.shapeInfo.relativeImagePath];
        self.image = self.shapeImage;
    }
    return self;
}


- (void)setImage:(UIImage *)image
{
    //todo crop image to show only path bounds
    [super setImage:image];
}

- (void)incremenentIndexAndFrame
{
    self.shapeInfo.index = [NSNumber numberWithInt:[self.shapeInfo.index intValue] + 1];
    
    self.frame = CGRectMake([self.shapeInfo.index floatValue] * kScrollableViewHeight, 0, kScrollableViewHeight, kScrollableViewHeight);
}

- (void)handlePanningGesture:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint initialCenter;
    static BOOL isSlide = FALSE;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint velocity = [recognizer velocityInView:self];
        if (- velocity.y < fabs(velocity.x) ) {
            isSlide = TRUE;
            initialCenter = ((UIScrollView *)self.superview).contentOffset;
        } else {
            isSlide = FALSE;
            initialCenter = self.center;
        }
    }
    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    if (isSlide) {
        CGFloat newCenter = MIN( ((UIScrollView *)self.superview).contentSize.width - kScreenWidth,MAX(initialCenter.x - translation.x, 0));
        ((UIScrollView *)self.superview).contentOffset = CGPointMake(newCenter,0);
    } else {
        CGPoint newCenterPoint = CGPointMake(initialCenter.x + translation.x,initialCenter.y + translation.y);
        self.center = newCenterPoint;
        
        if (initialCenter.y + translation.y < 0) {
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
            CGFloat x = newCenterPoint.x;
            CGFloat y = newCenterPoint.y + self.superview.superview.frame.size.height - kScrollableViewHeight;
            [self.controlledShapeView setAnchorPointToPosition:CGPointMake(x,y)];
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
