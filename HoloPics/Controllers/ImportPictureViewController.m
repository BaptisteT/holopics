//
//  ImportPictureViewController.m
//  HoloPics
//
//  Created by Baptiste Truchot on 5/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import "ImportPictureViewController.h"
#import "ImageUtilities.h"
#import "ImportPictureImageView.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

@interface ImportPictureViewController()

@property (weak, nonatomic) IBOutlet UIScrollView *unicolorScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *moviesScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *paintingsScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *celebritiesScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *animalsScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *containingScrollView;

@end

@implementation ImportPictureViewController


- (void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.containingScrollView.pagingEnabled = NO;
    self.containingScrollView.scrollsToTop = NO;
    self.containingScrollView.clipsToBounds = NO;
    [self.containingScrollView setContentSize:CGSizeMake(320, 1000)];
    
    [self.backgroundImage setImage:[UIImage imageNamed:@"empty_board"]];
    [ImageUtilities drawCustomNavBarWithLeftItem:@"back" rightItem:nil title:@"Import Background" sizeBig:NO inViewController:self];
    
    [self initUnicolorScrollView];
    // ugly code
    [self initScrollView:self.paintingsScrollView withCategory:@"paintings"];
    [self initScrollView:self.moviesScrollView withCategory:@"movies"];
    [self initScrollView:self.celebritiesScrollView withCategory:@"celebrities"];
    [self initScrollView:self.animalsScrollView withCategory:@"animals"];
}

- (void)initScrollView:(UIScrollView *)scrollView withCategory:(NSString *)category
{
    NSURLRequest *imageRequest; ImportPictureImageView *imageView; NSURL *url;
    
    scrollView.clipsToBounds = NO;
    scrollView.scrollsToTop = NO;
    
    scrollView.contentSize = CGSizeMake(kNumberOfImportPicsByCategory * kScrollableViewHeight, kScrollableViewHeight);
    
    for (int i = 0; i < kNumberOfImportPicsByCategory; i++)
    {
        url = [self getURLOfThumbImage:i fromCategory:category];
        imageRequest = [NSURLRequest requestWithURL:url];
        imageView = [ImportPictureImageView alloc];
        __weak ImportPictureImageView *weakImageView = imageView;
        [weakImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [scrollView addSubview: [imageView initWithController:self index:i category:category AndImage:image]];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
    }
}

- (void)initUnicolorScrollView
{
    NSArray *colorArray = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], [UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], [UIColor grayColor]];
    // Scroll view
    self.unicolorScrollView.clipsToBounds = NO;
    self.unicolorScrollView.scrollsToTop = NO;
    
    self.unicolorScrollView.contentSize = CGSizeMake(colorArray.count * kScrollableViewHeight, kScrollableViewHeight);
    NSInteger index = 0;
    for(UIColor *color in colorArray) {
        ImportPictureImageView *imageView = [[ImportPictureImageView alloc] initWithController:self index:index AndColor:color];
        [self.unicolorScrollView addSubview:imageView];
        index ++;
    }
}

- (void)backButtonClicked {
    [self.importPictureVCDelegate closeImportPictureController];
}

- (NSURL *)getURLOfThumbImage:(NSInteger)index fromCategory:(NSString *)category
{
    return [NSURL URLWithString:[kProdHolopicsBackgroundBaseURL stringByAppendingString:[category stringByAppendingFormat:@"%@/%lu%@",@"/thumbs",(long)index,@".jpg"]]];
}

- (void)popImportPictureViewController {
    [self.unicolorScrollView setHidden:YES];
    [self.moviesScrollView setHidden:YES];
    [self.celebritiesScrollView setHidden:YES];
    [self.animalsScrollView setHidden:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showHUD
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}




@end
