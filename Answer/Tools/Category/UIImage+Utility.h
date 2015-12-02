//
//  UIImage+Utility.h
//  
//
//  Created by wuyj on 14-12-1.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)targetSize;

@end
