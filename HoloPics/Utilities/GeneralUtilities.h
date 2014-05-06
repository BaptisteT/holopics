//
//  GeneralUtilities.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralUtilities : NSObject

+ (BOOL)connected;
+ (void)showMessage:(NSString *)text withTitle:(NSString *)title;

+ (NSString *)getDeviceID;
+ (NSUInteger)currentDateInMilliseconds;

+ (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;
+ (BOOL)isFirstOpening;

@end
