//
//  ScrollableShapeView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/16/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapeView.h"
#import "ShapeInfo.h"

@protocol ScrollableShapeViewDelegate;

@interface ScrollableShapeView : UIImageView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<ScrollableShapeViewDelegate> scrollableShapeViewDelegate;
@property (strong, nonatomic) ShapeInfo *shapeInfo;

- (id)initWithShapeInfo:(ShapeInfo *)shapeInfo;
- (void)incremenentIndexAndFrameOf:(int)position;

@end

@protocol ScrollableShapeViewDelegate

- (ShapeView *)insertNewShapeViewWithImage:(UIImage *)image andPath:(UIBezierPath *)path;
- (void)removeShape:(ShapeView *)shapeView;
- (void)setShapeCenter:(ShapeView *)shapeView ToPoint:(CGPoint)point;
- (void)deleteShapeFromScrollView:(ScrollableShapeView *)shapeInScrollView;

@end
