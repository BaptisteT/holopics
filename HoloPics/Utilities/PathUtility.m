//
//  PathUtility.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/24/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "PathUtility.h"
#import "Constants.h"

@implementation PathUtility

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

+ (void)closePath:(UIBezierPath *)path withInitialPoint:(CGPoint)initialPoint inRect:(CGSize)size
{
    CGPoint lastPoint = [path currentPoint];
    CGPoint lastPointBundaryProj = [PathUtility closestPointInBoundary:size fromPoint:lastPoint];
    CGPoint initialPointBundaryProj = [PathUtility closestPointInBoundary:size fromPoint:initialPoint];
    if ([PathUtility distanceBetweenPoint:lastPoint andPoint:initialPoint] < MAX([PathUtility distanceBetweenPoint:lastPoint andPoint:lastPointBundaryProj], [PathUtility distanceBetweenPoint:initialPoint andPoint:initialPointBundaryProj])) {
        [path addLineToPoint:initialPoint];
    } else {
        [path addLineToPoint:lastPointBundaryProj];
        
        if(initialPointBundaryProj.x != lastPointBundaryProj.x && initialPointBundaryProj.y != lastPointBundaryProj.y) {
            CGPoint interPoint1;
            if (lastPointBundaryProj.x == 0 || lastPointBundaryProj.x == size.width) {
                interPoint1.x = lastPointBundaryProj.x;
                interPoint1.y = (2 * lastPointBundaryProj.y > size.height)? size.height : 0;
            } else {
                interPoint1.x = (2 * lastPointBundaryProj.x > size.width)? size.width : 0;
                interPoint1.y = lastPointBundaryProj.y;
            }
            [path addLineToPoint:interPoint1];
            
            if(initialPointBundaryProj.x != interPoint1.x && initialPointBundaryProj.y != interPoint1.y) {
                CGPoint interPoint2;
                if (interPoint1.x == lastPointBundaryProj.x){
                    interPoint2.x = interPoint1.x ? 0 : size.width;
                    interPoint2.y = interPoint1.y;
                } else {
                    interPoint2.y = interPoint1.y ? 0 : size.height;
                    interPoint2.x = interPoint1.x;
                }
                [path addLineToPoint:interPoint2];
                
                if(initialPointBundaryProj.x != interPoint2.x && initialPointBundaryProj.y != interPoint2.y) {
                    CGPoint interPoint3;
                    if (interPoint2.x == interPoint1.x){
                        interPoint3.x = interPoint2.x ? 0 : size.width;
                        interPoint3.y = interPoint2.y;
                    } else {
                        interPoint3.y = interPoint2.y ? 0 : size.height;
                        interPoint3.x = interPoint2.x;
                    }
                    [path addLineToPoint:interPoint3];
                }
            }
        }
        [path addLineToPoint:initialPointBundaryProj];
        [path addLineToPoint:initialPoint];
    }
}

+ (BOOL) isMinimalSizePath:(UIBezierPath *)path
{
    CGFloat area = path.bounds.size.width * path.bounds.size.height;
    return area > kPathMinimalArea;
}


@end
