//
//  UIImage+Utility.m
//  BaiduTong
//
//  Created by wuyj on 14-12-1.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//把较大的图片重新调整大小
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize {
    //If scaleFactor is not touched, no scaling will occur
    // CGFloat scaleFactor = 1.0;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    //Deciding which factor to use to scale the image (factor = targetSize / imageSize)
    //    if (image.size.width > targetSize.width || image.size.height > targetSize.height)
    //       if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
    //           scaleFactor = targetSize.height / image.size.height; // scale to fit heigth.
    
    if (image.size.width > targetSize.width || image.size.height > targetSize.height) {
        CGFloat factorWidth = width / targetSize.width;
        CGFloat factorHeight = height / targetSize.height;
        if (factorWidth > factorHeight) {
            width = targetSize.width;
            height = height / factorWidth;
        }else{
            height = targetSize.height;
            width = width / factorHeight;
        }
    }
    
    if (NULL != &UIGraphicsBeginImageContextWithOptions && width>0)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 2.0);
    else
        UIGraphicsBeginImageContext(targetSize);
    
    //Creating the rect where the scaled image is drawn in
    CGRect rect = CGRectMake(0,
                             0,
                             width, height);
    
    //Draw the image into the rect
    [image drawInRect:rect];
    
    //Saving the image, ending image context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}



+ (UIImage *)screenShotImage:(UIView*)view {
    
    //创建图片
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //截取当前的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
