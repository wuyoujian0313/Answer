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

+ (QuestionInfoView *)sharedQuestionInfoView;

// 默认折叠文字
- (void)setQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave;
- (void)setQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave isFoldText:(BOOL)isfold;
- (CGFloat)viewHeight;

- (CGFloat)viewHeightByQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave isFoldText:(BOOL)isfold;
@end
