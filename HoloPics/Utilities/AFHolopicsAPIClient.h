//
//  AFHolopicsAPIClient.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/7/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface AFHolopicsAPIClient : AFHTTPSessionManager

+ (AFHolopicsAPIClient *)sharedClient;

+ (void)createHolopicsWithEncodedImage:(NSString *)encodedImage AndExecuteSuccess:(void(^)())successBlock failure:(void (^)())failureBlock;

+ (void)getHolopicsAtPage:(NSUInteger)page pageSize:(NSUInteger)pageSize AndExecuteSuccess:(void(^)(NSArray *holopics, NSInteger page))successBlock failure:(void (^)())failureBlock;

@end
