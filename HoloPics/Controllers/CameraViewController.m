//
//  CameraViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//
#import <Photos/Photos.h>

#import "CameraViewController.h"
#import "Constants.h"
#import "ImageUtilities.h"
#import "AFHolopicsAPIClient.h"
#import "ImportPictureViewController.h"

@interface CameraViewController ()

@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlipButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *importPictureButton;
@property (weak, nonatomic) IBOutlet UIButton *libraryButton;


@end

@implementation CameraViewController {
    BOOL isOpening;
}


// -------------------
// Life cycle
// -------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init and present full screen camera
    [self allocAndInitFullScreenCamera];
    
    // Libray Button
    self.importPictureButton.hidden = YES;
    self.libraryButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [[self.libraryButton layer] setBorderWidth:0.8f];
    [[self.libraryButton layer] setBorderColor:[UIColor blackColor].CGColor];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    
    PHImageManager *imgManager = [PHImageManager defaultManager];
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.synchronous = true;
    if (result.count > 0) {
        PHAsset *asset = [result objectAtIndex:result.count - 1];
        [imgManager requestImageForAsset:asset targetSize:self.libraryButton.frame.size
                             contentMode:PHImageContentModeAspectFill
                                 options:requestOptions
                           resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                               if (result)
                                   [self.libraryButton setImage:result forState:UIControlStateNormal];
                           }];
    }
    
    // design
    [ImageUtilities outerGlow:self.cancelButton];
    [ImageUtilities outerGlow:self.cameraFlipButton];
    [ImageUtilities outerGlow:self.importPictureButton];
    
    isOpening = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (isOpening) {
        [self presentViewController:self.imagePickerController animated:NO completion:NULL];
        isOpening = NO;
    }
}

// ----------------------------------------------------------
// Full screen Camera
// ----------------------------------------------------------

// Alloc the impage picker controller
- (void) allocAndInitFullScreenCamera
{
    // Create custom camera view
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        // Custom buttons
        imagePickerController.showsCameraControls = NO;
        imagePickerController.allowsEditing = NO;
        imagePickerController.navigationBarHidden=YES;
        
        NSString *xibName = @"CameraOverlayView";
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
        UIView* myView = [ nibViews objectAtIndex: 0];
        myView.frame = self.view.frame;
        
        imagePickerController.cameraOverlayView = myView;
        
        // Transform camera to get full screen (for iphone 5)
        // ugly code
        if (self.view.frame.size.height == 568) {
            double translationFactor = (self.view.frame.size.height - kCameraHeight) / 2;
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, translationFactor);
            imagePickerController.cameraViewTransform = translate;
            
            double rescalingRatio = self.view.frame.size.height / kCameraHeight;
            CGAffineTransform scale = CGAffineTransformScale(translate, rescalingRatio, rescalingRatio);
            imagePickerController.cameraViewTransform = scale;
        }
        
        // flash disactivated by default
        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    } else {
        imagePickerController.sourceType = self.sourceType;
    }
    
    self.imagePickerController = imagePickerController;
}

// Display the relevant part of the photo once taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editInfo
{
    UIImage *image =  [editInfo objectForKey:UIImagePickerControllerOriginalImage];

    UIImageOrientation orientation;
    double targetRatio = kScreenWidth / self.view.frame.size.height;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        // Force portrait, and avoid mirror of front camera
        orientation = self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront ? UIImageOrientationLeftMirrored : UIImageOrientationRight;
    } else {
        orientation = UIImageOrientationRight;
    }

    [self.cameraVCDelegate setBackgoundImage:[ImageUtilities cropImage:image toFitWidthOnHeightTargetRatio:targetRatio andOrientate:orientation]];
    
    [self closeCamera];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.imagePickerController.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        [self closeCamera];
    }
}

// --------------------------------
// Import VC delegate
// --------------------------------
- (void)closeCameraAndSetBackgoundImage:(UIImage *)image
{
    [self.cameraVCDelegate setBackgoundImage:image];
    [self closeCamera];
}
- (void)closeImportPictureController
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


// --------------------------------
// Camera button clicked
// --------------------------------

- (IBAction)ImportPictureButtonClicked:(id)sender {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    ImportPictureViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"ImportPictureController"];
    vc.importPictureVCDelegate = self;
    [self.imagePickerController presentViewController:vc animated:YES completion:nil];
}

- (IBAction)libraryButtonClicked:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

- (IBAction)takePictureButtonClicked:(id)sender {
    [self.imagePickerController takePicture];
}

- (IBAction)flipCameraButtonClicked:(id)sender
{
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront){
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self closeCamera];
}

- (void)closeCamera
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}


@end
