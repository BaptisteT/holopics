//
//  flexibleImageView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol flexibaleImageViewDelegate;

@interface flexibleImageView : UIImageView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <flexibaleImageViewDelegate> flexibaleImageViewDelegate;

- (id)initWithImage:(UIImage *)image andPath:(UIBezierPath *)path;

@end

@protocol flexibaleImageViewDelegate

- (void)unhideBinButton;
- (void)hideBinButton;
- (void)deleteView:(flexibleImageView *)view ifBinContainsPoint:(CGPoint)point;
@end
