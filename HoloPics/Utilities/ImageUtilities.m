//
//  ImageUtilities.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ImageUtilities.h"

@implementation ImageUtilities

+ (UIImage*)cropWidthOfImage:(UIImage*)image by:(CGFloat)croppedPercentage {
    
    if(croppedPercentage<0 || croppedPercentage>=1){
        // do nothing
        return image;
    }
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:1
                          orientation:UIImageOrientationUp];
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGRect cropRect; UIImageOrientation imageOrientation;
   
    if (imageWidth <= imageHeight) {
        // Create rectangle from middle of current image
        CGFloat croppedWidth = croppedPercentage * imageWidth;
        cropRect = CGRectMake(croppedWidth / 2, 0.0,
                                     imageWidth - croppedWidth, imageHeight);
        imageOrientation = UIImageOrientationRight;
    } else {
        CGFloat croppedHeight = croppedPercentage * imageHeight;
        cropRect = CGRectMake(0.0, croppedHeight /2,
                                     imageWidth, imageHeight - croppedHeight);
        imageOrientation = UIImageOrientationRight;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    // Create new cropped UIImage
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
                                                scale:1
                                          orientation:imageOrientation];
    CGImageRelease(imageRef);
    return croppedImage;
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
