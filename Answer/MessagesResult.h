//
//  MessagesResult.h
//  Answer
//
//  Created by wuyj on 15/12/14.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "NetResultBase.h"
#import "MessageInfo.h"

@interface MessagesResult : NetResultBase

@property (nonatomic, strong, getter=sysMessageList) NSArray *BaiduParserArray(sysMessageList,MessageInfo);

@end
