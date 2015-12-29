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

typedef NS_ENUM(NSInteger,QuestionInfoViewAction) {
    QuestionInfoViewAction_Attention = 103,
    QuestionInfoViewAction_PlayAudio = 200,
    QuestionInfoViewAction_PlayVideo = 202,
    QuestionInfoViewAction_ScanDetail,
    QuestionInfoViewAction_Answer = 308,
    QuestionInfoViewAction_Sharing = 309,
    QuestionInfoViewAction_RedPackage,
    QuestionInfoViewAction_Location,
};


@protocol QuestionInfoViewDelegate <NSObject>
- (void)questionInfoViewAction:(QuestionInfoViewAction)action questionInfo:(QuestionInfo*)question;
@end


#endif /* ProtocolDefine_h */
