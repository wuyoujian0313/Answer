//
//  UserAccountResult.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "UserAccountResult.h"

@implementation UserAccountResult


- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super init]) {
        
        self.balance               = [coder decodeObjectForKey:@"balance"];
        self.receivePacket         = [coder decodeObjectForKey:@"receivePacket"];
        self.sendPacket            = [coder decodeObjectForKey:@"sendPacket"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:_balance forKey:@"balance"];
    [coder encodeObject:_receivePacket forKey:@"receivePacket"];
    [coder encodeObject:_sendPacket forKey:@"sendPacket"];
}


- (id)copyWithZone:(nullable NSZone *)zone {
    [super copyWithZone:zone];
    
    UserAccountResult * temp = [[UserAccountResult alloc] init];
    [temp setBalance:_balance];
    [temp setReceivePacket:_receivePacket];
    [temp setSendPacket:_sendPacket];
    
    return temp;
}

@end
