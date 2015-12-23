//
//  UserInfo.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo


- (id)copyWithZone:(nullable NSZone *)zone {
    UserInfo * temp = [[UserInfo alloc] init];
    [temp setUuid:_uuid];
    [temp setUserName:_userName];
    [temp setUId:_uId];
    [temp setNickName:_nickName];
    [temp setPhoneNumber:_phoneNumber];
    [temp setAttentionNum:_attentionNum];
    [temp setFansNum:_fansNum];
    [temp setPassword:_password];
    [temp setLevel:_level];
    [temp setQq:_qq];
    [temp setWeixin:_weixin];
    [temp setHeadImage:_headImage];
    [temp setUpdateDate:_updateDate];
    
    return temp;
}

@end
