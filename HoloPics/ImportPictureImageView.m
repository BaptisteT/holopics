//
//  ImportPictureImageView.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ImportPictureImageView.h"
#import "ImportPictureViewController.h"
#import "Constants.h"
#import "ImageUtilities.h"

@interface ImportPictureImageView()

@property (weak, nonatomic) ImportPictureViewController *importPictureViewController; // owner
@property (strong, nonatomic) UIImage *attachedImage;
@property (strong, nonatomic) UITapGestureRecognizer *oneTapRecognizer;

@end


@implementation ImportPictureImageView

- (id)initWithController:(UIViewController *)controller index:(NSInteger)index AndImage:(UIImage *)image {
	if (self = [super initWithFrame:CGRectMake(index*kScrollableViewHeight, 0, kScrollableViewHeight, kScrollableViewHeight)]) {
        
        self.importPictureViewController = (ImportPictureViewController *)controller;
        
        if (image) {
            self.attachedImage = image;
            [self setImage:image];
        }
        
		self.layer.borderColor = [[UIColor blackColor] CGColor];
		self.layer.borderWidth = 1;
        
        self.oneTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneTapGesture:)];
        [self addGestureRecognizer:self.oneTapRecognizer];
        self.oneTapRecognizer.numberOfTapsRequired = 1;
        
        // User interaction
        self.userInteractionEnabled = YES;
        self.exclusiveTouch = YES;
	}
	return self;
}

- (id)initWithController:(UIViewController *)controller index:(NSInteger)index AndColor:(UIColor *)color {
    
    UIImage *image = [ImageUtilities imageInRect:[UIScreen mainScreen].bounds WithColor:color];
    self = [self initWithController:controller index:index AndImage:image];
    return self;
}

- (void)oneTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self.importPictureViewController.importPictureVCDelegate setBackgoundImage:self.attachedImage];
    [self.importPictureViewController popImportPictureViewController];
}

@end
