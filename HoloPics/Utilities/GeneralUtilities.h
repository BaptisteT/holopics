//
//  GeneralUtilities.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralUtilities : NSObject

+ (void)showMessage:(NSString *)text withTitle:(NSString *)title;

+ (float) distanceBetweenPoint:(CGPoint)p1 andPoint:(CGPoint)p2;

+ (CGPoint) closestPointInBoundary:(CGSize)size fromPoint:(CGPoint)p;

@end
