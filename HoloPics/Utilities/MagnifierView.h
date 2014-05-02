//
//  MagnifierView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/2/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagnifierView : UIView

@property (nonatomic, retain) UIView *viewToMagnify;
@property (nonatomic) CGPoint touchPoint;

- (void)setCenterPoint:(CGPoint)pt;

@end
