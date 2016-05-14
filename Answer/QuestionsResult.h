//
//  QuestionsResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
//#import "UserInfo.h"
#import "QuestionInfo.h"

@interface QuestionsResult : NetResultBase
//@property (nonatomic, strong,getter=userList) NSArray *BaiduParserArray(userList,UserInfo);
@property (nonatomic, strong,getter=twList) NSArray *BaiduParserArray(tuwenList,QuestionInfo);
@end
