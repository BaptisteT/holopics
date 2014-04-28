//
//  holoImageView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGPath.h>

@protocol holoImageViewDelegate;

@interface holoImageView : UIImageView

@property (weak, nonatomic) id <holoImageViewDelegate> holoImageViewDelegate;
@property (strong, nonatomic) UIImage *fullImage;
@property (strong, nonatomic) UIImage *insideImage;
@property (strong, nonatomic) UIImage *outsideImage;
@property (strong, nonatomic) UIBezierPath *globalPath;
@property (nonatomic) BOOL isInsideImageVisible;
@property (nonatomic) BOOL isOutsideImageVisible;

- (void)clearPathAndPictures;

@end

@protocol holoImageViewDelegate

- (void)takePictureAndDisplay:(NSInteger)displayMode;
- (void)letUserImportPhotoAndDisplay:(NSInteger)displayMode;

@end
