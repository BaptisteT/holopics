//
//  TimeUtilities.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/8/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "TimeUtilities.h"


#define ONE_MINUTE 60
#define ONE_HOUR (60 * ONE_MINUTE)
#define ONE_DAY (24 * ONE_HOUR)
#define ONE_WEEK (7 * ONE_DAY)

@implementation TimeUtilities

+ (NSTimeInterval)getHolopicAge:(NSString *)dateCreated
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Universal"]];
    NSDate *holopicDate = [dateFormatter dateFromString:dateCreated];
    return -[holopicDate timeIntervalSinceNow];
}

+ (NSString *)ageToString:(NSTimeInterval)age
{
    if (age > 0) {
        NSInteger weeks = age / ONE_WEEK;
        NSInteger days = age / ONE_DAY;
        NSInteger hours = age / ONE_HOUR;
        NSInteger minutes = age / ONE_MINUTE;
        
        if (weeks >= 1) {
            if (weeks > 1) {
                return [[NSString stringWithFormat:@"%ld", (long)weeks] stringByAppendingString:@" weeks"];
            } else {
                return [[NSString stringWithFormat:@"%ld", (long)weeks] stringByAppendingString:@" week"];
            }
        } else if (days >= 1) {
            if (days > 1) {
                return [[NSString stringWithFormat:@"%ld", (long)days] stringByAppendingString:@" days"];
            } else {
                return [[NSString stringWithFormat:@"%ld", (long)days] stringByAppendingString:@" day"];
            }
        } else if (hours >= 1) {
            if (hours > 1) {
                return [[NSString stringWithFormat:@"%ld", (long)hours] stringByAppendingString:@" hours"];
            } else {
                return [[NSString stringWithFormat:@"%ld", (long)hours] stringByAppendingString:@" hour"];
            }
        } else {
            if (minutes > 1) {
                return [[NSString stringWithFormat:@"%ld", (long)minutes] stringByAppendingString:@" minutes"];
            } else if (minutes == 1) {
                return [[NSString stringWithFormat:@"%ld", (long)minutes] stringByAppendingString:@" minute"];
            } else {
                return @"Now";
            }
        }
    } else {
        return @"Now";
    }
}

+ (NSString *)ageToShortString:(NSTimeInterval)age
{
    if (age > 0) {
        NSInteger weeks = age / ONE_WEEK;
        NSInteger days = age / ONE_DAY;
        NSInteger hours = age / ONE_HOUR;
        NSInteger minutes = age / ONE_MINUTE;
        
        if (weeks >= 1) {
            return [[NSString stringWithFormat:@"%ld", (long)weeks] stringByAppendingString:@"w"];
        } else if (days >= 1) {
            return [[NSString stringWithFormat:@"%ld", (long)days] stringByAppendingString:@"d"];
        } else if (hours >= 1) {
            return [[NSString stringWithFormat:@"%ld", (long)hours] stringByAppendingString:@"h"];
        } else {
            return [[NSString stringWithFormat:@"%ld", (long)minutes] stringByAppendingString:@"m"];
        }
    } else {
        return @"0m";
    }
}

@end