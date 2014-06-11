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

static const NSUInteger kCameraHeight = 426;// iphone 5
static const NSUInteger kScreenWidth = 320;

static const NSUInteger kPathMinimalArea = 200;

static const CGFloat    kLongPressTimeThreshold = 0.4f;
static const NSUInteger kContinuousMovementDistanceThreshold = 1;
static const NSUInteger kMinimumScale = 1;

static const NSUInteger kMaxNumberOfShapes = 20;
static const NSUInteger kMaxNumberOfShapesInMemory = 60;
static const NSUInteger kScrollableViewHeight = 80;
static const NSUInteger kScrollableViewInitialOffset = 60;
static const NSUInteger kMinDeleteVelocity = 200;

static const NSUInteger kShapeOptionOverlayMinLayerSize = 100;
static const NSUInteger kShapeOptionOverlayButtonSize = 40;

static const NSString * kAppTitle = @"Holopics";
static const NSUInteger kNumberOfImportPicsByCategory = 11;

#define FIRST_OPENING_PREF @"First Opening"
#define SHAPES_LOADED_PREF @"Has loaded shapes?"

// Production
static NSString * const kProdAFHolopicsAPIBaseURLString = @"http://holopics.herokuapp.com/";
static NSString * const kProdHolopicsImageBaseURL = @"http://s3.amazonaws.com/holopics-production/original/image_";
static NSString * const kProdHolopicsBackgroundBaseURL = @"http://s3.amazonaws.com/holopics-production/";
static NSString * const kProdHolopicsShapeBaseURL = @"http://s3.amazonaws.com/holopics-production/shapes/image_";
