//
//  ProtocolDefine.h
//  Answer
//
//  Created by wuyj on 15/12/25.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#ifndef ProtocolDefine_h
#define ProtocolDefine_h

#import "QuestionInfo.h"

typedef NS_ENUM(NSInteger,QuestionTableViewCellAction) {
    QuestionTableViewCellAction_Attention = 103,
    QuestionTableViewCellAction_PlayAudio = 200,
    QuestionTableViewCellAction_PlayVideo = 202,
    QuestionTableViewCellAction_ScanDetail,
    QuestionTableViewCellAction_Answer = 308,
    QuestionTableViewCellAction_Sharing = 309,
    QuestionTableViewCellAction_RedPackage,
    QuestionTableViewCellAction_Location,
};


@protocol QuestionTableViewCellDelegate <NSObject>
- (void)questionTableViewCellAction:(QuestionTableViewCellAction)action questionInfo:(QuestionInfo*)question;
@end


#endif /* ProtocolDefine_h */
