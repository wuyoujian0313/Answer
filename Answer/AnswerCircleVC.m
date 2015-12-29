//
//  AnswerCircleVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "AnswerCircleVC.h"
#import "QuestionsView.h"
#import "QuestionTableViewCell.h"
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "QuestionsResult.h"
#import "NetworkTask.h"
#import "User.h"

@interface AnswerCircleVC ()<QuestionInfoViewDelegate,AVAudioPlayerDelegate,NetworkTaskDelegate>
@property (nonatomic, strong) QuestionsView             *questionView;
@property(nonatomic,strong)AVAudioPlayer                *audioPlayer;
@property(nonatomic,strong)NSURL                        *recordedFile;
@property(nonatomic,copy)NSString                       *videoPathString;
@property(nonatomic,strong)MPMoviePlayerViewController  *moviePlayer;
@end

@implementation AnswerCircleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutQuestionView];
    [self requestQuestionList];
}

- (void)requestQuestionList {
    
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"all",@"wtype",
                          @"40",@"friendId",
                          @"1",@"latitude",
                          @"1",@"longitude",
                          [User sharedUser].user.uId,@"userId",nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetTuWenList
                                             forParam:param
                                             delegate:self
                                            resultObj:[[QuestionsResult alloc] init]
                                           customInfo:@"GetTuWenList"];
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
    self.questionView = [[QuestionsView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, screenWidth, screenHeight - navigationBarHeight - 49) delegate:self];
    
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


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"GetTuWenList"] && result) {
        
        QuestionsResult *qResult = (QuestionsResult*)result;
        [_questionView setQuestionsResult:qResult];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}




#pragma mark - QuestionInfoViewCellDelegate
- (void)questionInfoViewAction:(QuestionInfoViewAction)action questionInfo:(QuestionInfo*)question {
    
    switch (action) {
            
        case QuestionInfoViewAction_Attention:
            break;
        case QuestionInfoViewAction_PlayAudio:
            break;
        case QuestionInfoViewAction_PlayVideo:
            break;
        case QuestionInfoViewAction_ScanDetail:
            break;
        case QuestionInfoViewAction_Answer:
            break;
        case QuestionInfoViewAction_Sharing:
            break;
        case QuestionInfoViewAction_RedPackage:
            break;
        case QuestionInfoViewAction_Location:
            break;
            
        default:
            break;
    }
    
}


@end
