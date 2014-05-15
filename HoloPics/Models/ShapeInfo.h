//
//  ShapeInfo.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ShapeInfo : NSManagedObject

@property (nonatomic, retain) NSString * relativeImagePath;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) UIBezierPath * bezierPath;

@end
