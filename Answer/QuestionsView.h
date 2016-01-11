//
//  QuestionsView.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionsResult.h"
#import "ProtocolDefine.h"
#import "MJRefresh.h"


@interface QuestionsView : UIView

@property (nonatomic, weak) id<QuestionInfoViewDelegate> delegate;
@property (nonatomic, weak) id<MJRefreshBaseViewDelegate> refreshDelegate;

// 默认创建用户信息
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<QuestionInfoViewDelegate>)delegate;

// 是否需要布局用户信息
- (instancetype)initWithFrame:(CGRect)frame haveUserView:(BOOL)isHave delegate:(id<QuestionInfoViewDelegate>)delegate;

- (void)beginRefreshing;
- (void)addQuestionsResult:(QuestionsResult *)result;

- (void)reloadQuestionView;

@end
