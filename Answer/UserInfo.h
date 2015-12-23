//
//  UserInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject<NSCopying>

@property (nonatomic, copy) NSString        *uuid;
@property (nonatomic, copy) NSString        *userName;
@property (nonatomic, copy) NSString        *uId;
@property (nonatomic, copy) NSString        *nickName;
@property (nonatomic, copy) NSString        *phoneNumber;
@property (nonatomic, strong) NSNumber      *attentionNum;
@property (nonatomic, strong) NSNumber      *fansNum;
@property (nonatomic, copy) NSString        *password;
@property (nonatomic, strong) NSNumber      *level;
@property (nonatomic, copy) NSString        *qq;
@property (nonatomic, copy) NSString        *weixin;
@property (nonatomic, copy) NSString        *headImage;
@property (nonatomic, copy) NSString        *updateDate;

@end
