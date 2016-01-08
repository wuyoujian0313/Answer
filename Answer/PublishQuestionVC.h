//
//  PublishQuestionVC.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "BaseVC.h"
#import "QuestionBaseVC.h"

typedef NS_ENUM(NSInteger,PublishType) {
    PublishType_audio,
    PublishType_video,
    PublishType_image,
};

@interface PublishQuestionVC : QuestionBaseVC

@property(nonatomic, assign)PublishType  publishType;
@property(nonatomic, assign)NSInteger    recordDur;

// 视频key，在fileCache中
@property(nonatomic,copy)NSString       *videoKeyString;
// 语音key，在fileCache中
@property(nonatomic,copy)NSString       *recordFileKey;

// 视频截屏图片key 在SDImageCache中
// 图片key 在SDImageCache中
@property(nonatomic,copy)NSString       *imageKey;

@end
