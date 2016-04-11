//
//  GetNewMsgCountResult.h
//  Answer
//
//  Created by wuyoujian on 16/4/11.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "NetResultBase.h"

@interface GetNewMsgCountResult : NetResultBase

@property (nonatomic, copy) NSString *answerCount;
@property (nonatomic, copy) NSString *atmecount;
@property (nonatomic, copy) NSString *sysMsgCount;

@end
