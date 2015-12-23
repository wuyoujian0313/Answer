//
//  User.h
//  Answer
//
//  Created by wuyj on 15/12/20.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "UserAccountResult.h"

@interface User : NSObject

@property (nonatomic, copy) UserInfo              *user;
@property (nonatomic, copy) UserAccountResult     *account;


+ (User*)sharedUser;


@end
