//
//  TutoImageView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/6/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "TutoImageView.h"

@implementation TutoImageView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self setAlpha:0.7];
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}


@end
