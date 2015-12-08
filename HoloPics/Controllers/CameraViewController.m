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
    self.libraryButton.hidden = YES;
//    self.libraryButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [[self.libraryButton layer] setBorderWidth:0.8f];
//    [[self.libraryButton layer] setBorderColor:[UIColor blackColor].CGColor];
//    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
//    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
////         if (nil != group) {
////             // be sure to filter the group so you only get photos
////             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
////             [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
////                                     options:0
////                                  usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
////                                      if (nil != result) {
////                                          ALAssetRepresentation *repr = [result defaultRepresentation];
////                                          UIImageOrientation orientation = [ImageUtilities convertAssetOrientationToImageOrientation:[repr orientation]];
////                                          UIImage *img = [UIImage imageWithCGImage:[repr fullResolutionImage] scale:1 orientation:orientation];
////                                          [self.libraryButton setImage:img forState:UIControlStateNormal];
////                                          *stop = YES;
////                                      }
////                                  }];
////         }
//        
//             *stop = NO;
//         } failureBlock:^(NSError *error) {
//             NSLog(@"error: %@", error);
//         }];
    
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
    [AFHolopicsAPIClient sendAnalytics:@"AddLibraryOrCameraPicture" AndExecuteSuccess:nil failure:nil];
    
    [self.cameraVCDelegate setBackgoundImage:[ImageUtilities cropImage:image toFitWidthOnHeightTargetRatio:targetRatio andOrientate:orientation]];
    
    [self closeCamera];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [AFHolopicsAPIClient sendAnalytics:@"imagepicjerdidcancel" AndExecuteSuccess:nil failure:nil];
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
    [AFHolopicsAPIClient sendAnalytics:@"ImportClicked" AndExecuteSuccess:nil failure:nil];
}

- (IBAction)libraryButtonClicked:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [AFHolopicsAPIClient sendAnalytics:@"LibraryClicked" AndExecuteSuccess:nil failure:nil];
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
