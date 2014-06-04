//
//  ImportPictureImageView.h
//  HoloPics
//
//  Created by Baptiste Truchot on 5/28/14.
//  Copyright (c) 2014 Baptiste Truchot. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImportPictureImageView : UIImageView

- (id)initWithController:(UIViewController *)controller index:(NSInteger)index category:(NSString *)category AndImage:(UIImage *)image;
- (id)initWithController:(UIViewController *)controller index:(NSInteger)index AndColor:(UIColor *)color;

@end
