//
//  UserAccountResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetResultBase.h"

@interface UserAccountResult : NetResultBase

@property (nonatomic, strong) NSNumber     *balance;
@property (nonatomic, strong) NSNumber     *receivePacket;
@property (nonatomic, strong) NSNumber     *sendPacket;
@end
