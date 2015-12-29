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

@property (nonatomic, weak) id<QuestionTableViewCellDelegate>  delegate;

- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo;
- (CGFloat)cellHeight;

@end
