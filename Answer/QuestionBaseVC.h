//
//  QuestionBaseVC.h
//  Answer
//
//  Created by wuyj on 16/1/8.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "BaseVC.h"
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface QuestionBaseVC : BaseVC

@property(nonatomic,strong)AVAudioPlayer                *audioPlayer;
@property(nonatomic,strong)MPMoviePlayerViewController  *moviePlayer;


- (void)playVideo:(NSURL*)videoURL;
- (void)playReordFile:(NSURL*)audioURL;

- (void)stopPlay;

@end
