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
- (void)showHUD;
- (void)hideHUD;
@end

@protocol ImportPictureVCDelegate

- (void)closeImportPictureController;
- (void)closeCameraAndSetBackgoundImage:(UIImage *)image;

@end
