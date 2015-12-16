//
//  RewardInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardInfo : NSObject

@property (nonatomic, strong) NSNumber          *uuid;
@property (nonatomic, copy) NSString            *uId;
@property (nonatomic, strong) NSNumber          *tuwenId;
@property (nonatomic, strong) NSNumber          *type;
@property (nonatomic, strong) NSNumber          *amount;
@property (nonatomic, strong) NSNumber          *updateDate;


@end
