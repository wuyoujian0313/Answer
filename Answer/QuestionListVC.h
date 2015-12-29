//
//  QuestionListVC.h
//  Answer
//
//  Created by wuyj on 15/12/24.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"

typedef NS_ENUM(NSInteger, PageType) {
    PageType_MyQuestionList,
    PageType_FriendQuestionList,
    PageType_NearbyQuestionList,
};

@interface QuestionListVC : BaseVC
@property (nonatomic, assign) PageType      type;
@end
