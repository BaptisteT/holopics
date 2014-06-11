//
//  CameraViewController.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ImportPictureViewController.h"
#import <UIKit/UIKit.h>

@protocol CameraViewControllerDelegate;

@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, ImportPictureVCDelegate>

@property (weak, nonatomic) id<CameraViewControllerDelegate> cameraVCDelegate;
@property (nonatomic) UIImagePickerControllerSourceType sourceType;

@end

@protocol CameraViewControllerDelegate

- (void)setBackgoundImage:(UIImage *)image;


@end