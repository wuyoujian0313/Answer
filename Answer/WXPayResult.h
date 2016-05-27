//
//  WXPayResult.h
//  Answer
//
//  Created by wuyoujian on 16/5/25.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "NetResultBase.h"

@interface WXPayResult : NetResultBase

@property (nonatomic, copy) NSString        *noncestr;
@property (nonatomic, copy) NSString        *out_trade_no;
@property (nonatomic, copy) NSString        *prepayid;
@property (nonatomic, copy) NSString        *sign;
@property (nonatomic, copy) NSString        *timestamp;
@property (nonatomic, copy) NSString        *package;
@property (nonatomic, copy) NSString        *partnerid;
@property (nonatomic, copy) NSString        *appid;

@end
