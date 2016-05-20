//
//  AnswerInfo.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "AnswerInfo.h"

@implementation AnswerInfo

- (NSString *)headImage {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_headImage];
}

@end
