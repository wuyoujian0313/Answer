//
//  RewardListResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "RewardInfo.h"

@interface RewardListResult : NetResultBase
@property (nonatomic, strong, getter=rewards) NSArray *BaiduParserArray(rewardList,RewardInfo);

@end
