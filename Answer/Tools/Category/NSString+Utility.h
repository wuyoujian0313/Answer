//
//  NSString+LabelSize.h
//
//
//  Created by wuyj on 14/11/21.
//  Copyright (c) 2014年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utility)


- (CGSize)sizeWithFontCompatible:(UIFont *)font;
- (CGSize)sizeWithFontCompatible:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;


- (NSString*)md5EncodeUpper:(BOOL)upper;
+ (NSString*)UUID;
+ (NSString*)stringFormatPointer:(void*)pointer;
+ (NSString*)timeShortFormat:(int)seconds;
+ (NSString*)dateAndTimeFormat;

- (BOOL)isValidateEmail;
- (BOOL)isValidateMobile;
- (BOOL)isValidateURL;
- (BOOL)isHaveChinese;
- (NSString*)timeStringToChineseString;

-(NSString*)urlEncodingWithStringEncoding:(NSStringEncoding)encoding;

@end
