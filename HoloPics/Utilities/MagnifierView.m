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
	if (self = [super initWithFrame:CGRectMake(0, 0, 120, 120)]) {
		// make the circle-shape outline with a nice border.
		self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
		self.layer.borderWidth = 2;
		self.layer.cornerRadius = 60;
		self.layer.masksToBounds = YES;
	}
	return self;
}

- (void)setCenterPoint:(CGPoint)pt {
    self.touchPoint = pt;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, 1.2, 1.2);
	CGContextTranslateCTM(context,-1*(self.touchPoint.x),-1*(self.touchPoint.y));
	[self.viewToMagnify.layer renderInContext:context];
}



@end
