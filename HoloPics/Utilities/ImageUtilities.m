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

    UIImageOrientation originalOrientation = image.imageOrientation;
    
    // Put orientation up before cropping
    image = [UIImage imageWithCGImage:image.CGImage
                                scale:1
                          orientation:UIImageOrientationUp];
    // Crop
    CGRect cropRect;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    if(imageWidth <= imageHeight) {
        orientation = originalOrientation;
    }
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
            CGFloat croppedWidth = (1 - imageRatio / targetRatio) * imageWidth;
            cropRect = CGRectMake(croppedWidth / 2, 0.0, imageWidth - croppedWidth, imageHeight);
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

// code from
// http://stackoverflow.com/questions/3869692/iphone-flattening-a-uiimageview-and-subviews-to-image-blank-image
+ (UIImage*)imageFromView:(UIView *)view
{
    // Create a graphics context with the target size
    CGSize imageSize = [view bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Center the context around the view's anchor point
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    // Apply the view's transform about the anchor point
    CGContextConcatCTM(context, [view transform]);
    // Offset by the portion of the bounds left of and above the anchor point
    CGContextTranslateCTM(context,
                          -[view bounds].size.width * [[view layer] anchorPoint].x,
                          -[view bounds].size.height * [[view layer] anchorPoint].y);
    
    // Render the layer hierarchy to the current context
    [[view layer] renderInContext:context];
    
    // Restore the context
    CGContextRestoreGState(context);
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
