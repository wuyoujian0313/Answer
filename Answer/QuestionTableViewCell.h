//
//  QuestionTableViewCell.h
//  Answer
//
//  Created by wuyj on 15/12/16.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionInfo.h"
#import "UserInfo.h"
#import "ProtocolDefine.h"

@interface QuestionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<QuestionInfoViewDelegate>  delegate;
- (void)setQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave;
+ (CGFloat)cellHeightByQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave;

@end
