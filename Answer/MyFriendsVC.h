//
//  MyFriendsVC.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"

typedef NS_ENUM(NSInteger,EnterType) {
    EnterType_FromPublishQuestion,
    EnterType_FromMe,
};

@protocol SelectedFriendIdsDelegate <NSObject>

@optional
// 用,拼接
-(void)setSelectedFriendIds:(NSString*)idsString number:(NSInteger)number;

@end

@interface MyFriendsVC : BaseVC

@property (nonatomic, assign) EnterType     enterType;
@property (nonatomic, copy) NSString        *selectedIdsString;
@property (nonatomic, weak) id<SelectedFriendIdsDelegate> delegate;



@end
