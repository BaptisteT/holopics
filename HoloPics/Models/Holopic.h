//
//  Holopic.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/7/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Holopic : NSObject

+ (NSArray *)rawHolopicsToInstances:(NSArray *)rawHolopics;
+ (Holopic *)rawHolopicToInstance:(id)rawHolopic;
- (NSURL *)getHolopicImageURL;

@property (nonatomic) NSUInteger identifier;

@end
