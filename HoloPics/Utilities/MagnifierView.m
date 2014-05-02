//
//  MagnifierView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/2/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "MagnifierView.h"

@implementation MagnifierView


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:CGRectMake(0, 0, 80, 80)]) {
		// make the circle-shape outline with a nice border.
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 3;
		self.layer.cornerRadius = 40;
		self.layer.masksToBounds = YES;
	}
	return self;
}

- (void)setCenterPoint:(CGPoint)pt {
    self.touchPoint = pt;
    // whenever touchPoint is set, update the position of the magnifier (to just above what's being magnified)
    self.center = CGPointMake(pt.x, pt.y-70);
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, 1.5, 1.5);
	CGContextTranslateCTM(context,-1*(self.touchPoint.x),-1*(self.touchPoint.y));
	[self.viewToMagnify.layer renderInContext:context];
}



@end
