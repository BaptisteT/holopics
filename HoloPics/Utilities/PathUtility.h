//
//  PathUtility.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/24/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PathUtility : NSObject

+ (float) distanceBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

+ (CGPoint) closestPointInBoundary:(CGSize)size fromPoint:(CGPoint)p;

+ (void)closePath:(UIBezierPath *)path withInitialPoint:(CGPoint)initialPoint inRect:(CGSize)size;

+ (BOOL) isMinimalSizePath:(UIBezierPath *)path;

+ (CGRect) getSquareBoundsOfPath:(UIBezierPath *)path;

@end
