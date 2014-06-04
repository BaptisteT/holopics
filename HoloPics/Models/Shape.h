//
//  Shape.h
//  HoloPics
//
//  Created by Baptiste Truchot on 6/4/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shape : NSObject

+ (NSArray *)rawShapesToInstances:(NSArray *)rawShapes;
+ (Shape *)rawShapeToInstance:(id)rawShape;
- (NSURL *)getShapeImageURL;

@property (nonatomic) NSUInteger identifier;
@property (strong, nonatomic) UIBezierPath *bezierpath;

@end
