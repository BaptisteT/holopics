//
//  AFHolopicsAPIClient.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/7/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "AFHolopicsAPIClient.h"
#import "Constants.h"

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


@end
