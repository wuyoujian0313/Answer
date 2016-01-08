//
//  QuestionInfoView.h
//  Answer
//
//  Created by wuyj on 15/12/29.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionInfo.h"
#import "UserInfo.h"
#import "ProtocolDefine.h"

@interface QuestionInfoView : UIView

@property (nonatomic, weak) id<QuestionInfoViewDelegate>  delegate;

// 默认折叠文字
- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo;

- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo isFoldText:(BOOL)isfold;
- (CGFloat)viewHeight;
@end
