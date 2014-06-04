//
//  ImportPictureViewController.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImportPictureVCDelegate;

@interface ImportPictureViewController : UIViewController

@property (weak, nonatomic) id <ImportPictureVCDelegate> importPictureVCDelegate;

- (void)popImportPictureViewController;

@end

@protocol ImportPictureVCDelegate

- (void)setBackgoundImage:(UIImage *)image;
- (void)showHUD;
- (void)hideHUD;

@end
