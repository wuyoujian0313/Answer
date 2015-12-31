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

@property (nonatomic, copy) NSString              *phoneNumber;
@property (nonatomic, copy) UserInfo              *user;
@property (nonatomic, copy) UserAccountResult     *account;
@property (nonatomic, strong) NSMutableArray      *friends;


+ (User*)sharedUser;

- (void)clearUser;
- (void)saveToUserDefault;
- (void)loadFromUserDefault;

- (void)saveFriends:(NSArray*)friends;

@end
