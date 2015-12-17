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


typedef NS_ENUM(NSInteger,QuestionTableViewCellAction) {
    QuestionTableViewCellAction_PlayAudio,
    QuestionTableViewCellAction_PlayVideo,
    QuestionTableViewCellAction_ScanDetail,
    QuestionTableViewCellAction_Sharing,
    QuestionTableViewCellAction_RedPackage,
    QuestionTableViewCellAction_Location,
};


@class QuestionTableViewCell;
@protocol QuestionTableViewCellDelegate <NSObject>
- (void)questionTableViewCellAction:(QuestionTableViewCellAction)action questionInfo:(QuestionInfo*)question;
@end

@interface QuestionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<QuestionTableViewCellDelegate>  delegate;

- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo;
- (CGFloat)cellHeight;

@end
