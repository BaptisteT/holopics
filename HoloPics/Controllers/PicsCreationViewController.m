//
//  PicsCreationViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 4/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "PicsCreationViewController.h"
#import "Constants.h"
#import "ImageUtilities.h"
#import "GeneralUtilities.h"
#import "holoImageView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <AWSS3/AmazonS3Client.h>


@interface PicsCreationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (weak, nonatomic) IBOutlet holoImageView *holoImageView;
@property (strong, nonatomic) UIImage *lastPicture;
@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic) NSInteger displayMode;


@end

@implementation PicsCreationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.displayMode = kNoDisplay;
    // Alloc and init full screen camera
    [self allocAndInitFullScreenCamera];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Present the camera
    [self presentViewController:self.imagePickerController animated:NO completion:NULL];
    [self.saveButton setHidden:YES];
    // Make this controller the delegate of holoImageView
    self.holoImageView.holoImageViewDelegate = self;
}

// ----------------------------------------------------------
// Full screen Camera
// ----------------------------------------------------------

// Alloc the impage picker controller
- (void) allocAndInitFullScreenCamera
{
    // Create custom camera view
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = self;
    
    // Custom buttons
    imagePickerController.showsCameraControls = NO;
    imagePickerController.allowsEditing = NO;
    imagePickerController.navigationBarHidden=YES;
    
    NSString *xibName = self.view.frame.size.height == 568 ? @"CameraOverlayView" : @"CameraOverlayView_small";
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
    UIView* myView = [ nibViews objectAtIndex: 0];
    
    imagePickerController.cameraOverlayView = myView;
    
    // Transform camera to get full screen
    double translationFactor = (self.view.frame.size.height - kCameraHeight) / 2;
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, translationFactor);
    imagePickerController.cameraViewTransform = translate;
    
    double rescalingRatio = self.view.frame.size.height / kCameraHeight;
    CGAffineTransform scale = CGAffineTransformScale(translate, rescalingRatio, rescalingRatio);
    imagePickerController.cameraViewTransform = scale;
    
    // flash disactivated by default
    imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    
    self.library = [ALAssetsLibrary new];
    self.imagePickerController = imagePickerController;
}

// Display the relevant part of the photo once taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editInfo
{
    UIImage *image =  [editInfo objectForKey:UIImagePickerControllerOriginalImage];
    
    // Force portrait, and avoid mirror of front camera
    UIImageOrientation orientation = self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
    
    // Crop
    double rescalingRatio = self.view.frame.size.height / kCameraHeight;
    self.lastPicture = [ImageUtilities imageWithImage:[ImageUtilities cropWidthOfImage:image by:(1-1/rescalingRatio) andOrientate:orientation] scaledToSize:self.holoImageView.bounds.size];
    
    // Display partly or fully on camera overlay
    if (self.displayMode == kDisplayFull) {
        self.holoImageView.fullImage = self.lastPicture;
        [self.holoImageView setImage:self.holoImageView.fullImage];
    } else if (self.displayMode == kDisplayInside) {
        self.holoImageView.insideImage = [ImageUtilities drawFromImage:self.lastPicture insidePath:self.holoImageView.globalPath];
        if(self.holoImageView.isOutsideImageVisible) {
            // full composed picture
            self.holoImageView.fullImage = [ImageUtilities addImage:self.holoImageView.insideImage toImage:self.holoImageView.outsideImage withSize:self.holoImageView.bounds.size];
            [self.holoImageView setImage:self.holoImageView.fullImage];
            [self.saveButton setHidden:NO];
        } else {
            [self.holoImageView setImage:self.holoImageView.insideImage];
        }
        self.holoImageView.isInsideImageVisible = YES;
    } else if (self.displayMode == kDisplayOutside) {
        self.holoImageView.outsideImage = [ImageUtilities drawFromImage:self.lastPicture outsidePath:self.holoImageView.globalPath];
        if(self.holoImageView.isInsideImageVisible) {
            // full composed picture
            self.holoImageView.fullImage = [ImageUtilities addImage:self.holoImageView.insideImage toImage:self.holoImageView.outsideImage withSize:self.holoImageView.bounds.size];
            [self.holoImageView setImage:self.holoImageView.fullImage];
            [self.saveButton setHidden:NO];
        } else {
            [self.holoImageView setImage:self.holoImageView.outsideImage];
        }
        self.holoImageView.isOutsideImageVisible = YES;
    }
    self.displayMode = kNoDisplay;
}

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

- (IBAction)saveButtonClicked:(id)sender {
    [self saveImageToFileSystem:self.holoImageView.image];
    
    if(!self.holoImageView.fullImage) {
        [GeneralUtilities showMessage:NSLocalizedStringFromTable (@"incomplete_pics", @"Strings", @"comment") withTitle:nil];
        return;
    }
    if (![GeneralUtilities connected]) {
        [GeneralUtilities showMessage:NSLocalizedStringFromTable (@"no_connection", @"Strings", @"comment") withTitle:nil];
    } else {
        NSString *imageName = [[GeneralUtilities getDeviceID] stringByAppendingFormat:@"--%lu", (unsigned long)[GeneralUtilities currentDateInMilliseconds]];
        AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        [s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:S3_BUCKET]];
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:imageName inBucket:S3_BUCKET];
        por.contentType = @"image/jpeg";
        NSData *imageData = UIImageJPEGRepresentation (self.holoImageView.fullImage, 0.8);
        por.data = imageData;
        [s3 putObject:por];
        [GeneralUtilities showMessage:@"Image saved" withTitle:nil];
        [self cancelButtonClicked:nil];
    }
}

// Front camera
- (IBAction)flipCameraButtonClicked:(id)sender {
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

// Cancel path and pictures
- (IBAction)cancelButtonClicked:(id)sender {
    [self.holoImageView clearPathAndPictures];
    self.lastPicture = nil;
    [self.saveButton setHidden:YES];
}

// Take picture and display it on overlay
- (void)takePictureAndDisplay:(NSInteger)displayMode {
    self.displayMode = displayMode;
    [self.imagePickerController takePicture];
}




@end
