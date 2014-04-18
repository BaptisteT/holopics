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

+ (UIImage*)cropWidthOfImage:(UIImage*)image by:(CGFloat)croppedPercentage;

+ (ALAssetOrientation)convertImageOrientationToAssetOrientation:(UIImageOrientation)orientation;

+ (UIImage *)drawFromImage:(UIImage *)fullImage outsidePath:(UIBezierPath *)path;

+ (UIImage *)drawFromImage:(UIImage *)fullImage insidePath:(UIBezierPath *)path;

+ (UIImage *) addImage:(UIImage *)img toImage:(UIImage *)img2 withSize:(CGSize)size;

@end