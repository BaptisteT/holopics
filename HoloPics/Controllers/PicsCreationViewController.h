//
//  PicsCreationViewController.h
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackgroundView.h"
#import "ShapeView.h"

@interface PicsCreationViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, BackgroundViewDelegate, UIActionSheetDelegate, ShapeViewDelegate>

@property (strong, nonatomic) UIImage *forwardedImage;

@end
