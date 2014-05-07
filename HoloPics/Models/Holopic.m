//
//  Holopic.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/7/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "Holopic.h"
#import "Constants.h"

#define HOLOPIC_ID @"id"

@implementation Holopic

+ (NSArray *)rawHolopicsToInstances:(NSArray *)rawHolopics
{
    NSMutableArray *holopics = [[NSMutableArray alloc] init];
    
    for (NSDictionary *rawHolopic in rawHolopics) {
        [holopics addObject:[Holopic rawHolopicToInstance:rawHolopic]];
    }
    
    return holopics;
}

+ (Holopic *)rawHolopicToInstance:(id)rawHolopic
{
    Holopic *holopic = [[Holopic alloc] init];
    holopic.identifier = [[rawHolopic objectForKey:HOLOPIC_ID] integerValue];
    
    return holopic;
}

- (NSURL *)getHolopicImageURL
{
    return [NSURL URLWithString:[kProdHolopicsImageBaseURL stringByAppendingFormat:@"%lu",(unsigned long)self.identifier]];
}

@end
