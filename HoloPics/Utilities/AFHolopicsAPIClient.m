//
//  AFHolopicsAPIClient.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/7/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "AFHolopicsAPIClient.h"
#import "Constants.h"
#import "Holopic.h"

@implementation AFHolopicsAPIClient


// ---------------
// Utilities
// ---------------

+ (AFHolopicsAPIClient *)sharedClient
{
    static AFHolopicsAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFHolopicsAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kProdAFHolopicsAPIBaseURLString  ]];
        
        NSOperationQueue *operationQueue = _sharedClient.operationQueue;
        [_sharedClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if(status == AFNetworkReachabilityStatusNotReachable) {
                [operationQueue cancelAllOperations];
            }
        }];
    });
    
    return _sharedClient;
}

+ (NSString *)getBasePath
{
    return [NSString stringWithFormat:@"api/v%@/", kApiVersion];
}


// ---------------
// Holopics
// ---------------

// Create holopics
+ (void)createHolopicsWithEncodedImage:(NSString *)encodedImage AndExecuteSuccess:(void(^)())successBlock failure:(void (^)())failureBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    AFHolopicsAPIClient *manager = [AFHolopicsAPIClient sharedClient];
    [parameters setObject:encodedImage forKey:@"avatar"];
    
    NSString *path = [[AFHolopicsAPIClient getBasePath] stringByAppendingString:@"holopics.json"];
    
    [manager POST:path parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
        if (successBlock) {
            successBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}


// Retrieve most recent holopics
+ (void)getHolopicsAtPage:(NSUInteger)page pageSize:(NSUInteger)pageSize AndExecuteSuccess:(void(^)(NSArray *holopics, NSInteger page))successBlock failure:(void (^)())failureBlock
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:[NSNumber numberWithLong:page] forKey:@"page"];
    [parameters setObject:[NSNumber numberWithLong:pageSize] forKey:@"page_size"];
    
    NSString *path = [[AFHolopicsAPIClient getBasePath] stringByAppendingString:@"holopics.json"];
    
    [[AFHolopicsAPIClient sharedClient] GET:path parameters:parameters success:^(NSURLSessionDataTask *task, id JSON) {
        NSDictionary *result = [JSON valueForKeyPath:@"result"];
        NSArray *rawHolopics = [result valueForKeyPath:@"holopics"];
        NSInteger page = [[result valueForKeyPath:@"page"] integerValue];
        successBlock([Holopic rawHolopicsToInstances:rawHolopics], page);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}


@end
