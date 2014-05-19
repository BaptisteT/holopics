//
//  ShapeView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShapeViewDelegate;

@interface ShapeView : UIImageView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <ShapeViewDelegate> shapeViewDelegate;
@property (strong, nonatomic) UIImage *attachedImage;

- (id)initWithImage:(UIImage *)image frame:(CGRect)frame andPath:(UIBezierPath *)path;
- (void)setAnchorPointToPosition:(CGPoint)anchorPointPosition;

@end

@protocol ShapeViewDelegate

//- (void)deleteView:(ShapeView *)view ifBinContainsPoint:(CGPoint)point;
- (void)sendToFrontView:(ShapeView *)view;

@end