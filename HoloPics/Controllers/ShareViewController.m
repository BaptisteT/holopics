//
//  ShareViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/9/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ShareViewController.h"
#import "AFHolopicsAPIClient.h"
#import "ImageUtilities.h"
#import "GeneralUtilities.h"
#import "MBProgressHUD.h"
#import "Holopic.h"

@interface ShareViewController ()

@property (strong, nonatomic) ALAssetsLibrary *library;
@property (weak, nonatomic) IBOutlet UIButton *saveLibraryButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ShareViewController

// --------------------------------
// Life Cycle
// --------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.library = [ALAssetsLibrary new];
    
    // Design
    [self.saveLibraryButton setTitle:NSLocalizedStringFromTable (@"image_saved", @"Strings", @"comment") forState:UIControlStateDisabled];
    [self.saveLibraryButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [[self.saveLibraryButton layer] setBorderWidth:1.0f];
    [[self.saveLibraryButton layer] setBorderColor:[UIColor blackColor].CGColor];
    [self.imageView setImage:self.imageToShare];
    [self.imageView setAlpha:0.3f];
    
    [ImageUtilities drawCustomNavBarWithLeftItem:@"back" rightItem:nil title:@"Publish " sizeBig:NO inViewController:self];
}


// -------------------------------
// Button actions
// -------------------------------
- (IBAction)publishButtonClicked:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *encodedImage = [ImageUtilities encodeToBase64String:self.imageToShare];
    
    // Results block
    typedef void (^SuccessBlock)(Holopic *);
    SuccessBlock successBlock = ^(Holopic *holopic) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    typedef void (^FailureBlock)(NSURLSessionDataTask *);
    FailureBlock failureBlock = ^(NSURLSessionDataTask *task) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSString *title = NSLocalizedStringFromTable (@"create_holopic_failed_title", @"Strings", @"comment");
        NSString *message = NSLocalizedStringFromTable (@"create_holopic_failed_message", @"Strings", @"comment");
        [GeneralUtilities showMessage:message withTitle:title];
    };
    
    // Request
    [AFHolopicsAPIClient createHolopicsWithEncodedImage:encodedImage AndExecuteSuccess:successBlock failure:failureBlock];
}

- (IBAction)saveLibraryButtonClicked:(id)sender {
    if (self.saveLibraryButton.enabled) {
        self.saveLibraryButton.enabled = NO;
        [[self.saveLibraryButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [self saveImageToFileSystem:self.imageToShare];
    }
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

// --------------------------------
// Utilities
// --------------------------------

// Save image in the phone
- (void)saveImageToFileSystem:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    
    [weakSelf.library writeImageToSavedPhotosAlbum:[image CGImage]
                                       orientation:[ImageUtilities convertImageOrientationToAssetOrientation:image.imageOrientation]
                                   completionBlock:^(NSURL *assetURL, NSError *error){
                                       if (error) {
                                           [GeneralUtilities showMessage:[error localizedDescription] withTitle:@"Error Saving"];
                                       }
                                   }];
}

@end
