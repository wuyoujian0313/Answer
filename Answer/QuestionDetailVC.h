//
//  QuestionDetailVC.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"

@class QuestionInfo;
@class UserInfo;
@interface QuestionDetailVC : BaseVC
@property (nonatomic, strong) QuestionInfo              *questionInfo;
@property (nonatomic, strong) UserInfo                  *userInfo;
@end
