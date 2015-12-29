//
//  QuestionListVC.m
//  Answer
//
//  Created by wuyj on 15/12/24.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionListVC.h"
#import "QuestionsView.h"
#import "QuestionTableViewCell.h"
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface QuestionListVC ()<QuestionTableViewCellDelegate,AVAudioPlayerDelegate>
@property (nonatomic, strong) QuestionsView             *questionView;
@property(nonatomic,strong)AVAudioPlayer                *audioPlayer;
@property(nonatomic,strong)NSURL                        *recordedFile;
@property(nonatomic,copy)NSString                       *videoPathString;
@property(nonatomic,strong)MPMoviePlayerViewController  *moviePlayer;

@end

@implementation QuestionListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_type == PageType_FriendQuestionList) {
        [self setNavTitle:@"好友问题"];
    } else if ( _type == PageType_MyQuestionList) {
        [self setNavTitle:@"我的问题"];
    } else if (_type == PageType_NearbyQuestionList) {
        [self setNavTitle:@"附近问题"];
    } else {
        [self setNavTitle:@"问题列表"];
    }
    
    [self layoutQuestionView];
}

-(void)playVideo:(UIButton*)sender {
    
    NSString  *src = _videoPathString;
    if (src != nil && [src length] > 0) {
        self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:src]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer.moviePlayer];
        [_moviePlayer.moviePlayer setControlStyle: MPMovieControlStyleFullscreen];
        [_moviePlayer.moviePlayer play];
        
        [self presentMoviePlayerViewControllerAnimated:_moviePlayer];
    }
}

-(void)movieFinishedCallback:(NSNotification *)notify {
    
    MPMoviePlayerController *vc = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:vc];
    
    _moviePlayer = nil;
}

-(void)playReordFile {
    
    //#if TARGET_IPHONE_SIMULATOR
    //#elif TARGET_OS_IPHONE
    // 播放
    NSError *playerError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordedFile error:&playerError];
    if (_audioPlayer) {
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    //#endif
    
}

- (void)layoutQuestionView {
    
    BOOL haveUserView = YES;
    if ( _type == PageType_MyQuestionList) {
        haveUserView = NO;
    }

    self.questionView = [[QuestionsView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, screenWidth, screenHeight - navigationBarHeight) haveUserView:haveUserView delegate:self];
    
    [self.view addSubview:_questionView];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_audioPlayer stop];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_audioPlayer stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - QuestionTableViewCellDelegate
- (void)questionTableViewCellAction:(QuestionTableViewCellAction)action questionInfo:(QuestionInfo*)question {
}


@end
