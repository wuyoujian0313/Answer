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

#define  UserDefault_User               @"UserDefault_User"
#define  UserDefault_Account            @"UserDefault_Account"
#define  UserDefault_Friends            @"UserDefault_Friends"
#define  UserDefault_PhoneNumber        @"UserDefault_PhoneNumber"
#define  UserDefault_UsersHeadImage     @"UserDefault_UsersHeadImage"


@interface User : NSObject

@property (nonatomic, copy) NSString                        *phoneNumber;
@property (nonatomic, copy) UserInfo                        *user;
@property (nonatomic, copy) UserAccountResult               *account;
@property (nonatomic, strong) NSMutableSet<NSString*>       *friendIds;


+ (User*)sharedUser;

- (void)clearUser;
- (void)saveToUserDefault;
- (void)loadFromUserDefault;

- (void)saveFriends:(NSArray<NSString*>*)friends;
- (BOOL)isFriend:(NSString*)userId;
- (BOOL)isMe:(NSString*)userId;
- (void)deleteFriend:(NSString*)userId;
- (void)addFriend:(NSString*)userId;

- (NSString *)getUserHeadImageURLWithPhoneNumber:(NSString *)phoneNumber;

@end
