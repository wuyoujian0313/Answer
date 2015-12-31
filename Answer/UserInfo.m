//
//  UserInfo.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super init]) {
        
        self.uuid               = [coder decodeObjectForKey:@"uuid"];
        self.userName           = [coder decodeObjectForKey:@"userName"];
        self.uId                = [coder decodeObjectForKey:@"uId"];
        self.nickName           = [coder decodeObjectForKey:@"nickName"];
        self.phoneNumber        = [coder decodeObjectForKey:@"phoneNumber"];
        self.guanzhuCount       = [coder decodeObjectForKey:@"guanzhuCount"];
        self.fansNum            = [coder decodeObjectForKey:@"fansNum"];
        self.password           = [coder decodeObjectForKey:@"password"];
        self.level              = [coder decodeObjectForKey:@"level"];
        self.qq                 = [coder decodeObjectForKey:@"qq"];
        self.weixin             = [coder decodeObjectForKey:@"weixin"];
        self.headImage          = [coder decodeObjectForKey:@"headImage"];
        self.updateDate         = [coder decodeObjectForKey:@"updateDate"];
        
    }
    return self;
}

- (NSString *)headImage {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_headImage];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:_uuid forKey:@"uuid"];
    [coder encodeObject:_userName forKey:@"userName"];
    [coder encodeObject:_uId forKey:@"uId"];
    [coder encodeObject:_nickName forKey:@"nickName"];
    [coder encodeObject:_phoneNumber forKey:@"phoneNumber"];
    [coder encodeObject:_guanzhuCount forKey:@"guanzhuCount"];
    [coder encodeObject:_fansNum forKey:@"fansNum"];
    [coder encodeObject:_password forKey:@"password"];
    [coder encodeObject:_level forKey:@"level"];
    [coder encodeObject:_qq forKey:@"qq"];
    [coder encodeObject:_weixin forKey:@"weixin"];
    [coder encodeObject:_headImage forKey:@"headImage"];
    [coder encodeObject:_updateDate forKey:@"updateDate"];
    
}

- (id)copyWithZone:(nullable NSZone *)zone {
    UserInfo * temp = [[UserInfo alloc] init];
    [temp setUuid:_uuid];
    [temp setUserName:_userName];
    [temp setUId:_uId];
    [temp setNickName:_nickName];
    [temp setPhoneNumber:_phoneNumber];
    [temp setGuanzhuCount:_guanzhuCount];
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
