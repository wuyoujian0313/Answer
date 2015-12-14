//
//  MyFriendsResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "UserInfo.h"

@interface MyFriendsResult : NetResultBase

@property (nonatomic, strong,getter=friendList) NSArray *BaiduParserArray(friendList,UserInfo);

@end
