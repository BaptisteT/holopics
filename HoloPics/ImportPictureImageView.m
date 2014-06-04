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
#import "AFHolopicsAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "GeneralUtilities.h"

@interface ImportPictureImageView()

@property (weak, nonatomic) ImportPictureViewController *importPictureViewController; // owner
@property (strong, nonatomic) UIImage *thumbImage;
@property (strong, nonatomic) UITapGestureRecognizer *oneTapRecognizer;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSString *category;


@end


@implementation ImportPictureImageView

- (id)initWithController:(UIViewController *)controller index:(NSInteger)index category:(NSString *)category AndImage:(UIImage *)image {
	if (self = [super initWithFrame:CGRectMake(index*kScrollableViewHeight, 0, kScrollableViewHeight, kScrollableViewHeight)]) {
        
        self.index = index;
        self.category = category;
        self.importPictureViewController = (ImportPictureViewController *)controller;
        
        if (image) {
            self.thumbImage = image;
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
    self = [self initWithController:controller index:index category:nil AndImage:image];
    return self;
}

- (void)oneTapGesture:(UITapGestureRecognizer *)recognizer
{
    [AFHolopicsAPIClient sendAnalytics:@"ImportBackground" AndExecuteSuccess:nil failure:nil];
    if (self.category) {
        if (![GeneralUtilities connected]) {
             [GeneralUtilities showMessage:@"Please try again" withTitle:@"There is a problem with your connection"];
            return;
        }
        NSURL *url = [self getURLOfBackgroundImage:self.index fromCategory:self.category];
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
        __weak typeof(self) weakSelf = self;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(failureResponseSelector:) userInfo:self.importPictureViewController repeats:NO];
        [weakSelf.importPictureViewController.importPictureVCDelegate showHUD];
        [self setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [weakSelf.importPictureViewController.importPictureVCDelegate setBackgoundImage:image];
            [weakSelf.importPictureViewController.importPictureVCDelegate hideHUD];
            [timer invalidate];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [weakSelf.importPictureViewController.importPictureVCDelegate hideHUD];
            [GeneralUtilities showMessage:@"Sorry, we could not import this picture" withTitle:nil];
            [timer invalidate];
        }];
        [weakSelf.importPictureViewController popImportPictureViewController];
    } else {
        [self.importPictureViewController.importPictureVCDelegate setBackgoundImage:self.thumbImage];
        [self.importPictureViewController popImportPictureViewController];
    }
}

- (NSURL *)getURLOfBackgroundImage:(NSInteger)index fromCategory:(NSString *)category
{
    return [NSURL URLWithString:[kProdHolopicsBackgroundBaseURL stringByAppendingString:[category stringByAppendingFormat:@"/%lu%@",(long)index,@".jpg"]]];
}

- (void)failureResponseSelector:(NSTimer *)timer
{
    ImportPictureViewController *controller = timer.userInfo;
    [controller.importPictureVCDelegate hideHUD];
    [GeneralUtilities showMessage:@"Sorry, we could not import this picture" withTitle:nil];
}

@end
