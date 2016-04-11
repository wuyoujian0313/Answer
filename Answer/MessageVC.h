//
//  MessageVC.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"
#import "GetNewMsgCountResult.h"

@interface MessageVC : BaseVC

- (void)reloadData:(GetNewMsgCountResult *)msgCountRec;



@end
