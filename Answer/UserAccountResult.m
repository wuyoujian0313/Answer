//
//  UserAccountResult.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "UserAccountResult.h"

//@property (nonatomic, strong) NSNumber     *balance;
//@property (nonatomic, strong) NSNumber     *receivePacket;
//@property (nonatomic, strong) NSNumber     *sendPacket;

@implementation UserAccountResult

- (id)copyWithZone:(nullable NSZone *)zone {
    [super copyWithZone:zone];
    
    UserAccountResult * temp = [[UserAccountResult alloc] init];
    [temp setBalance:_balance];
    [temp setReceivePacket:_receivePacket];
    [temp setSendPacket:_sendPacket];
    
    return temp;
}

@end
