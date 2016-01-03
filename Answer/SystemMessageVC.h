//
//  SystemMessageVC.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"

typedef NS_ENUM(NSInteger, MessageType) {
    MessageType_system,
    MessageType_answerMyQuestion,
    MessageType_atMe,
    
};

@interface SystemMessageVC : BaseVC

@property(nonatomic, assign) MessageType messageType;

@end
