//
//  User.m
//  Answer
//
//  Created by wuyj on 15/12/20.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "User.h"

@interface User ()
@property (nonatomic,strong) NSMutableDictionary *userHeads;
@end

@implementation User

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (instancetype)init {
    if (self = [super init]) {
        self.user = [[UserInfo alloc] init];
        self.account = [[UserAccountResult alloc] init];
        self.friends = [[NSMutableArray alloc] init];
        self.userHeads = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveToUserDefault)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadFromUserDefault)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

+ (User *)sharedUser {
    
    static User *userShared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userShared = [[self alloc] init];
    });
    return userShared;
}

- (NSString *)getUserHeadImageURLWithPhoneNumber:(NSString *)phoneNumber {
    return [_userHeads objectForKey:phoneNumber];
}

- (BOOL)isFriend:(NSString*)userId {
    
    BOOL isFriend = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",userId];
    NSArray *users = [_friends filteredArrayUsingPredicate:predicate];
    
    if (users && [users count]) {
        isFriend = YES;
    }
    
    return isFriend;
}

- (void)saveFriends:(NSArray*)friends {
    if (friends) {
        [self.friends addObjectsFromArray:friends];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (_friends) {
        
        NSData *friendsData = [NSKeyedArchiver archivedDataWithRootObject:_friends];
        [userDefaults setObject:friendsData forKey:UserDefault_Friends];
    }
    [userDefaults synchronize];
}

- (void)clearUser {
    
    self.user = [[UserInfo alloc] init];;
    self.account = [[UserAccountResult alloc] init];
    self.friends = [[NSMutableArray alloc] init];
    self.userHeads = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:UserDefault_User];
    [userDefaults setObject:nil forKey:UserDefault_Account];
    [userDefaults setObject:nil forKey:UserDefault_Friends];
    [userDefaults synchronize];
}


- (void)saveToUserDefault {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (_user) {
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:_user];
        [userDefaults setObject:userData forKey:UserDefault_User];

        [self.userHeads setObject:_user.headImage forKey:_user.phoneNumber];
        [userDefaults setObject:_userHeads forKey:UserDefault_UsersHeadImage];
        
        NSString *phoneNumber = [userDefaults objectForKey:UserDefault_PhoneNumber];
        if (![_user.phoneNumber isEqualToString:phoneNumber]) {
            [userDefaults setObject:_user.phoneNumber forKey:UserDefault_PhoneNumber];
        }
    }
    
    if (_account) {
        NSData *accountData = [NSKeyedArchiver archivedDataWithRootObject:_account];
        [userDefaults setObject:accountData forKey:UserDefault_Account];
    }
    
    if (_friends) {
        
        NSData *friendsData = [NSKeyedArchiver archivedDataWithRootObject:_friends];
        [userDefaults setObject:friendsData forKey:UserDefault_Friends];
    }
    
    [userDefaults synchronize];
}

- (void)loadFromUserDefault {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.phoneNumber = [userDefaults objectForKey:UserDefault_PhoneNumber];
    
    NSMutableDictionary *hh = [userDefaults objectForKey:UserDefault_UsersHeadImage];
    if (hh) {
        [self.userHeads addEntriesFromDictionary:hh];
    }
    

    NSData *userData = [userDefaults objectForKey:UserDefault_User];
    if (userData && [userData isKindOfClass:[NSData class]]) {
        UserInfo *user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
        if (user) {
            self.user = user;
            self.phoneNumber = self.user.phoneNumber;
        }
    }

    NSData *accountData = [userDefaults objectForKey:UserDefault_Account];
    if (accountData && [accountData isKindOfClass:[NSData class]]) {
        UserAccountResult *account = [NSKeyedUnarchiver unarchiveObjectWithData:accountData];
        if (account) {
            self.account = account;
        }
    }
    
    NSData *friendsData = [userDefaults objectForKey:UserDefault_Friends];
    if (friendsData && [friendsData isKindOfClass:[NSData class]]) {
        NSArray *friends = [NSKeyedUnarchiver unarchiveObjectWithData:friendsData];
        if (friends) {
            [self.friends addObjectsFromArray:friends];
        }
    }
}

@end
