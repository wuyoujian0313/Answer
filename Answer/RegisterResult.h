//
//  RegisterResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "UserInfo.h"
#import "UserAccount.h"

@interface RegisterResult : NetResultBase
@property (nonatomic, strong) UserInfo      *user;
@property (nonatomic, strong) UserAccount   *account;
@end
