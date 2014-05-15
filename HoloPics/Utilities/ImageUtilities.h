//
//  ImageUtilities.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageUtilities : NSObject

+ (UIImage*)cropImage:(UIImage*)image toFitWidthOnHeightTargetRatio:(CGFloat)targetRatio andOrientate:(UIImageOrientation)orientation;

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (ALAssetOrientation)convertImageOrientationToAssetOrientation:(UIImageOrientation)orientation;

+ (UIImage *)drawFromImage:(UIImage *)fullImage outsidePath:(UIBezierPath *)path;

+ (UIImage *)drawFromImage:(UIImage *)fullImage insidePath:(UIBezierPath *)path;

+ (UIImage *) addImage:(UIImage *)img toImage:(UIImage *)img2 withSize:(CGSize)size;

+ (void)drawPath:(UIBezierPath *)path inImageView:(UIImageView *)view;

+ (UIImage*)imageFromView:(UIView *)view;

+ (NSString *)encodeToBase64String:(UIImage *)image;

+ (void)outerGlow:(UIView *)view;

+ (void)drawCustomNavBarWithLeftItem:(NSString *)leftItem rightItem:(NSString *)rightItem title:(NSString *)title sizeBig:(BOOL)sizeBig inViewController:(UIViewController *)viewController;

+ (void)saveImageInAppDirectory:(UIImage *)image;

+ (UIImage *)getImageSavedLocally:(NSInteger)imageIndex;

@end