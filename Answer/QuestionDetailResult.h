//
//  QuestionDetailResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "UserInfo.h"
#import "QuestionInfo.h"
#import "AnswerInfo.h"


@interface QuestionDetailResult : NetResultBase
@property (nonatomic, strong) UserInfo          *user;
@property (nonatomic, strong) QuestionInfo      *tw;
@property (nonatomic, strong,getter=twAnswers) NSArray           *BaiduParserArray(twAnswers,AnswerInfo);

@end
