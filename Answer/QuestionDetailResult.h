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
//@property (nonatomic, strong) UserInfo                              *user;
@property (nonatomic, strong) QuestionInfo                          *tuwen;
@property (nonatomic, strong,getter=answers) NSArray              *BaiduParserArray(answers,AnswerInfo);
//@property (nonatomic, strong,getter=userList) NSArray              *BaiduParserArray(userList,UserInfo);

@end
