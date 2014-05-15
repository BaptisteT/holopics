//
//  BackgroundView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGPath.h>

@protocol BackgroundViewDelegate;

@interface BackgroundView : UIImageView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id <BackgroundViewDelegate> backgroundViewDelegate;
@property (strong, nonatomic) UIImage *fullImage;
@property (strong, nonatomic) UIBezierPath *globalPath;

- (void)clearPathAndPictures;

@end

@protocol BackgroundViewDelegate

- (void)takePictureAndDisplay;
- (void)letUserImportPhotoAndDisplay;
- (void)createFlexibleSubView;
- (void)hideSaveandUnhideFlipButton;
- (void)handleCustomCameraZoom:(UIPinchGestureRecognizer *)recogniser;

@end
