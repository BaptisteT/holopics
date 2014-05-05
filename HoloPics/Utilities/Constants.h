//
//  Constants.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Constants : NSObject

@end

static const NSUInteger kCameraHeight = 426;
static const NSUInteger kScreenWidth = 320;

static const NSUInteger kPathMinimalArea = 100;

static const CGFloat    kLongPressTimeThreshold = 0.4f;
static const NSUInteger kContinuousMovementDistanceThreshold = 1;
static const NSUInteger kMinimumPinchDelta = 1;

static const NSUInteger kMaxNumberOfFlexibleImage = 20;

// TODO remove this
#define ACCESS_KEY_ID @"AKIAJTBDZSZ2Y3XF5XYQ"
#define SECRET_KEY @"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"
#define S3_URL @"street-shout1.s3.amazonaws.com/"
#define S3_BUCKET @"holopics-production"