//
//  User.m
//  Answer
//
//  Created by wuyj on 15/12/20.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "User.h"

@implementation User


+ (User *)sharedUser {
    static User *userShared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userShared = [[super allocWithZone:NULL] init];
    });
    return userShared;
}

@end
