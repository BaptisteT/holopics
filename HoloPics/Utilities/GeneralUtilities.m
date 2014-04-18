//
//  GeneralUtilities.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "GeneralUtilities.h"

@implementation GeneralUtilities

// Show an alert message
+ (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:nil
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

+ (float) distanceBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2
{
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
}

+ (CGPoint) closestPointInBoundary:(CGSize)size fromPoint:(CGPoint)p
{
    CGPoint closestBoundaryPoint;
    if (MIN(p.x,size.width - p.x) < MIN(p.y,size.height - p.y)) {
        closestBoundaryPoint.x = (2*p.x > size.width)? size.width : 0;
        closestBoundaryPoint.y = p.y;
    } else {
        closestBoundaryPoint.x = p.x;
        closestBoundaryPoint.y = (2*p.y > size.height)? size.height : 0;
    }
    return closestBoundaryPoint;
}

@end

