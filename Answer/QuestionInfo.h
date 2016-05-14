//
//  QuestionInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionInfo : NSObject<NSCoding>

@property (nonatomic, copy) NSString        *uuid;
@property (nonatomic, copy) NSString        *uId;
@property (nonatomic, copy) NSString        *userId;
@property (nonatomic, copy) NSString        *nickName;
@property (nonatomic, copy) NSString        *phoneNumber;
@property (nonatomic, copy) NSString        *headImage;
@property (nonatomic, copy) NSString        *mediaType;//2 图片，1 视频 ，0音频
@property (nonatomic, copy, getter=mediaURL) NSString        *mediaURL;
@property (nonatomic, copy, getter=thumbnail) NSString       *thumbnail;
@property (nonatomic, copy) NSString        *content;
@property (nonatomic, copy) NSString        *longitude;
@property (nonatomic, copy) NSString        *latitude;
@property (nonatomic, copy) NSString        *address;
@property (nonatomic, copy) NSString        *isAnonymous;
@property (nonatomic, copy) NSString        *hasBestAnswer;
@property (nonatomic, copy) NSString        *reward;
@property (nonatomic, copy) NSString        *updateDate;
@property (nonatomic, copy) NSString        *fenlei;
@property (nonatomic, copy) NSString        *mediaLen;
@property (nonatomic, copy) NSString        *mark;

@end
