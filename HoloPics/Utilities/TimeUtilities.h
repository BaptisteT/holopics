//
//  TimeUtilities.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/8/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtilities : NSObject

+ (NSTimeInterval)getHolopicAge:(NSString *)dateCreated;

+ (NSString *)ageToString:(NSTimeInterval)age;

+ (NSString *)ageToShortString:(NSTimeInterval)age;

@end
