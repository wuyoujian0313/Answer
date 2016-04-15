//
//  RewardInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardInfo : NSObject

@property (nonatomic, copy) NSString            *uuid;
@property (nonatomic, copy) NSString            *uId;
@property (nonatomic, copy) NSString            *tuwenId;
@property (nonatomic, copy) NSString            *type; // 类型
@property (nonatomic, copy) NSString            *status; // 状态
@property (nonatomic, copy) NSString            *amount;
@property (nonatomic, copy) NSString            *updateDate;
@property (nonatomic, copy) NSString            *createDate;
@property (nonatomic, copy) NSString            *out_trade_no;
@property (nonatomic, copy) NSString            *cost;
@property (nonatomic, copy) NSString            *targetAccount;


@end
