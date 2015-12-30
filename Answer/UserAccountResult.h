//
//  UserAccountResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetResultBase.h"

@interface UserAccountResult : NetResultBase<NSCopying>

@property (nonatomic, copy) NSString     *balance;
@property (nonatomic, copy) NSString     *receivePacket;
@property (nonatomic, copy) NSString     *sendPacket;
@end
