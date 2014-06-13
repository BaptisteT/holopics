//
//  TutoImageView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/6/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "TutoImageView.h"
#import "ImageUtilities.h"

@interface TutoImageView()
@property (strong, nonatomic) UIButton *button;
@end

@implementation TutoImageView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
//        [self setAlpha:0.7];
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 30)];
        [self.button setImage:[UIImage imageNamed:@"delete_button"] forState:UIControlStateNormal];
        [ImageUtilities outerGlow:self.button];
        self.button.userInteractionEnabled = NO;
        [self addSubview:self.button];
        self.userInteractionEnabled = YES;
    }
    return self;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}


@end
