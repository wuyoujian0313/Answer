//
//  RewardInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RewardInfo : NSObject

@property (nonatomic, assign) NSInteger         uuid;
@property (nonatomic, copy) NSString            *uId;
@property (nonatomic, assign) NSInteger         tuwenId;
@property (nonatomic, assign) NSInteger         type;
@property (nonatomic, assign) CGFloat           amount;
@property (nonatomic, copy) NSString            *updateDate;


@end
