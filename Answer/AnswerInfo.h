//
//  AnswerInfo.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnswerInfo : NSObject

@property (nonatomic, assign) NSInteger         uuid;
@property (nonatomic, copy) NSString            *uId;
@property (nonatomic, assign) NSInteger         *tuwenId;
@property (nonatomic, assign) NSInteger         *isBestAnswer;
@property (nonatomic, copy) NSString            *content;
@property (nonatomic, copy) NSString            *updateDate;

@end
