//
//  Shape.m
//  HoloPics
//
//  Created by Baptiste Truchot on 6/4/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "Shape.h"
#import "Constants.h"

#define SHAPE_ID @"id"
#define SHAPE_PATH @"path"

@implementation Shape

+ (NSArray *)rawShapesToInstances:(NSArray *)rawShapes
{
    NSMutableArray *shapes = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rawShape in rawShapes) {
        [shapes addObject:[Shape rawShapeToInstance:rawShape]];
    }
    
    return shapes;
}

+ (Shape *)rawShapeToInstance:(id)rawShape
{
    Shape *shape = [[Shape alloc] init];
    shape.identifier = [[rawShape objectForKey:SHAPE_ID] integerValue];
    NSString *encodePath = [rawShape objectForKey:SHAPE_PATH];
    NSData *pathData = [[NSData alloc] initWithBase64EncodedString:encodePath options:kNilOptions];
    shape.bezierpath = [NSKeyedUnarchiver unarchiveObjectWithData:pathData];
    return shape;
}

- (NSURL *)getShapeImageURL
{
    return [NSURL URLWithString:[kProdHolopicsShapeBaseURL stringByAppendingFormat:@"%lu",(unsigned long)self.identifier]];
}


@end
