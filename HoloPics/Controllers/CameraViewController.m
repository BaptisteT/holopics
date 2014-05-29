//
//  CameraViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/15/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "CameraViewController.h"
#import "Constants.h"
#import "ImageUtilities.h"

@interface CameraViewController ()

@property (strong, nonatomic) UIImagePickerController * imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraFlipButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) BOOL flashOn;

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
    
    // design
    [ImageUtilities outerGlow:self.flashButton];
    [ImageUtilities outerGlow:self.cancelButton];
    [ImageUtilities outerGlow:self.cameraFlipButton];
    
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
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.delegate = self;
    
    if (self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
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
            double translationFactor = (568 - kCameraHeight) / 2;
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, translationFactor);
            imagePickerController.cameraViewTransform = translate;
            
            double rescalingRatio = 568 / kCameraHeight;
            CGAffineTransform scale = CGAffineTransformScale(translate, rescalingRatio, rescalingRatio);
            imagePickerController.cameraViewTransform = scale;
        }
        
        // flash disactivated by default
        self.flashOn = NO;
        imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    } else {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
    [self closeCamera];
}

// --------------------------------
// Camera button clicked
// --------------------------------

- (IBAction)flashButtonClicked:(id)sender {
    if(self.flashOn == NO){
        [self.flashButton setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        self.flashOn = YES;
    } else {
        [self.flashButton setImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        self.flashOn = NO;
    }
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
