//
//  QuestionInfo.m
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionInfo.h"

@implementation QuestionInfo

- (NSString *)mediaURL {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_mediaURL];
}

- (NSString *)thumbnail {
    return [NSString stringWithFormat:@"%@/%@",kNetworkServerIP,_thumbnail];
}

@end
