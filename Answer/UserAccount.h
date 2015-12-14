//
//  UserAccount.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject

@property (nonatomic, assign) CGFloat       balance;
@property (nonatomic, assign) NSInteger     receivePacket;
@property (nonatomic, assign) NSInteger     sendPacket;
@end
