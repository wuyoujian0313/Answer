//
//  QuestionListVC.h
//  Answer
//
//  Created by wuyj on 15/12/24.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"
#import "QuestionBaseVC.h"

typedef NS_ENUM(NSInteger, PageType) {
    PageType_MyQuestionList,
    PageType_FriendQuestionList,
    PageType_MyFriendQuestionList,
    PageType_NearbyQuestionList,
    PageType_AtMeQuestionList,
};

@interface QuestionListVC : QuestionBaseVC
@property (nonatomic, assign) PageType      type;
@property (nonatomic, copy) NSString        *userId;
@property (nonatomic, copy) NSString        *friendId;
@end
