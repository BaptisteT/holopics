//
//  ShapeOptionOverlayView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/22/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapeView.h"

@interface ShapeOptionOverlayView : UIView

@property (weak, nonatomic) IBOutlet UIButton *resizeButton;

- (id)initWithShapeView:(ShapeView *)shapeView;
-(void)revertTransformForOverlayButtons:(CGAffineTransform)transform scaleTransform:(CGAffineTransform)scaleTransform;

@end
