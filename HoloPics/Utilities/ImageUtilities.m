//
//  ImageUtilities.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ImageUtilities.h"

@implementation ImageUtilities

+ (UIImage*)cropImage:(UIImage*)image toFitWidthOnHeightTargetRatio:(CGFloat)targetRatio andOrientate:(UIImageOrientation)orientation {

    // Put orientation up before cropping
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:1
                          orientation:UIImageOrientationUp];
    
    // Crop
    CGRect cropRect;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat imageRatio = MIN(imageWidth,imageHeight) / MAX(imageWidth,imageHeight);
    
    if (imageRatio > targetRatio) {
        if (imageWidth <= imageHeight) {
            // Create rectangle from middle of current image
            CGFloat croppedWidth = (1 - targetRatio / imageRatio ) * imageWidth;
            cropRect = CGRectMake(croppedWidth / 2, 0.0, imageWidth - croppedWidth, imageHeight);
        } else {
            CGFloat croppedHeight = (1 - targetRatio / imageRatio ) * imageHeight;
            cropRect = CGRectMake(0.0, croppedHeight / 2, imageWidth, imageHeight - croppedHeight);
        }
    } else {
        if (imageWidth <= imageHeight) {
            // Create rectangle from middle of current image
            CGFloat croppedHeight = (1 - imageRatio / targetRatio) * imageHeight;
            cropRect = CGRectMake(0.0, croppedHeight / 2, imageWidth, imageHeight - croppedHeight);
        } else {
            CGFloat croppedWidth = (1 - imageRatio / targetRatio) * imageHeight;
            cropRect = CGRectMake(0.0, croppedWidth /2, imageWidth, imageHeight - croppedWidth);
        }
    }
    // Create new cropped UIImage
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:1
                                          orientation:orientation];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (UIImage*)cropWidthOfImage:(UIImage*)image by:(CGFloat)croppedPercentage andOrientate:(UIImageOrientation)orientation {
    
    if(croppedPercentage<0 || croppedPercentage>=1){
        // do nothing
        return image;
    }
    // Put orientation up before cropping
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:1
                          orientation:UIImageOrientationUp];
    
    // Crop
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGRect cropRect;
   
    if (imageWidth <= imageHeight) {
        // Create rectangle from middle of current image
        CGFloat croppedWidth = croppedPercentage * imageWidth;
        cropRect = CGRectMake(croppedWidth / 2, 0.0, imageWidth - croppedWidth, imageHeight);
    } else {
        CGFloat croppedHeight = croppedPercentage * imageHeight;
        cropRect = CGRectMake(0.0, croppedHeight /2, imageWidth, imageHeight - croppedHeight);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    // Create new cropped UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:1
                                          orientation:orientation];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (ALAssetOrientation)convertImageOrientationToAssetOrientation:(UIImageOrientation)orientation
{
    if (orientation == UIImageOrientationUp) {
        return ALAssetOrientationUp;
    } else if (orientation == UIImageOrientationDown) {
        return ALAssetOrientationDown;
    } else if (orientation == UIImageOrientationLeft) {
        return ALAssetOrientationLeft;
    } else if (orientation == UIImageOrientationRight) {
        return ALAssetOrientationRight;
    } else {
        return 0;
    }
}

// Draw the image outside the path
+ (UIImage *)drawFromImage:(UIImage *)fullImage outsidePath:(UIBezierPath *)path
{
    UIGraphicsBeginImageContextWithOptions(fullImage.size, NO, 0);
    // Clip to the bezier path and clear that portion of the image.
    CGContextRef context =  UIGraphicsGetCurrentContext();
    
    [fullImage drawAtPoint:CGPointZero];
    CGContextAddPath(context,path.CGPath);
    CGContextClip(context);
    CGContextClearRect(context,CGRectMake(0,0,fullImage.size.width,fullImage.size.height));
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// Draw the image inside the path
+ (UIImage *)drawFromImage:(UIImage *)fullImage insidePath:(UIBezierPath *)path
{
    UIGraphicsBeginImageContextWithOptions(fullImage.size, NO, 0);
    [path addClip];
    [fullImage drawInRect:CGRectMake(0,0,fullImage.size.width,fullImage.size.height)];
    [fullImage drawAtPoint:CGPointZero];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// Merge two images
+ (UIImage *) addImage:(UIImage *)img toImage:(UIImage *)img2 withSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    [img drawAtPoint:CGPointZero];
    [img2 drawAtPoint: CGPointZero];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end
