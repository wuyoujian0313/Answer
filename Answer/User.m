//
//  User.m
//  Answer
//
//  Created by wuyj on 15/12/20.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "User.h"

#define  UserDefault_User               @"UserDefault_User"
#define  UserDefault_Account            @"UserDefault_Account"
#define  UserDefault_PhoneNumber        @"UserDefault_PhoneNumber"

@implementation User


+ (User *)sharedUser {
    static User *userShared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userShared = [[self alloc] init];
        userShared.user = [[UserInfo alloc] init];
        userShared.account = [[UserAccountResult alloc] init];
    });
    return userShared;
}

- (void)clearUser {
    self.user = [[UserInfo alloc] init];;
    self.account = [[UserAccountResult alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:UserDefault_User];
    [userDefaults setObject:nil forKey:UserDefault_Account];
    [userDefaults synchronize];
}


- (void)saveToUserDefault {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (_user) {
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:_user];
        [userDefaults setObject:userData forKey:UserDefault_User];
        
        [userDefaults setObject:_user.phoneNumber forKey:UserDefault_PhoneNumber];
    }
    
    if (_account) {
        NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:_account];
        [userDefaults setObject:accountData forKey:UserDefault_Account];
    }
    
    [userDefaults synchronize];
}

- (void)loadFromUserDefault {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.phoneNumber = [userDefaults objectForKey:UserDefault_PhoneNumber];

    NSData *userData = [userDefaults objectForKey:UserDefault_User];
    if (userData && [userData isKindOfClass:[NSData class]]) {
        UserInfo *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        if (user) {
            self.user = user;
            self.phoneNumber = self.user.phoneNumber;
        }
    }
    self.account = [userDefaults objectForKey:UserDefault_Account];
    
    NSData *accountData = [userDefaults objectForKey:UserDefault_User];
    if (accountData && [accountData isKindOfClass:[NSData class]]) {
        UserAccountResult *account = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
        if (account) {
            self.account = account;
        }
    }
}

@end
