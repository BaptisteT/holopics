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

// API Version
static NSString * const kApiVersion = @"1";

static const NSUInteger kCameraHeight = 426;
static const NSUInteger kScreenWidth = 320;

static const NSUInteger kPathMinimalArea = 200;

static const CGFloat    kLongPressTimeThreshold = 0.4f;
static const NSUInteger kContinuousMovementDistanceThreshold = 1;
static const NSUInteger kMinimumPinchDelta = 1;

static const NSUInteger kMaxNumberOfShapes = 50;
static const NSUInteger kScrollableViewHeight = 80;
static const NSUInteger kScrollableViewInitialOffset = 60;
static const NSUInteger kMinDeleteVelocity = 200;

static const NSUInteger kShapeOptionOverlayMinLayerSize = 100;
static const NSUInteger kShapeOptionOverlayButtonSize = 40;


#define FIRST_OPENING_PREF @"First Opening"

// Production
static NSString * const kProdAFHolopicsAPIBaseURLString = @"http://holopics.herokuapp.com/";
static NSString * const kProdHolopicsImageBaseURL = @"http://s3.amazonaws.com/holopics-production/original/image_";
