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
#import "QuestionDetailVC.h"
#import "MyFriendsResult.h"


@interface AnswerCircleVC ()<QuestionInfoViewDelegate,AVAudioPlayerDelegate,NetworkTaskDelegate,MJRefreshBaseViewDelegate>
@property(nonatomic,strong)QuestionsView                *questionView;
@property(nonatomic,strong)AVAudioPlayer                *audioPlayer;
@property(nonatomic,strong)NSURL                        *recordedFile;
@property(nonatomic,copy)NSString                       *videoPathString;
@property(nonatomic,strong)MPMoviePlayerViewController  *moviePlayer;
@property(nonatomic,assign)BOOL                         isFristRefreshing;
@end

@implementation AnswerCircleVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutQuestionView];
    _isFristRefreshing = YES;
    [_questionView beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestQuestionList)
                                                 name:NotificationChangeUserHeadImage
                                               object:nil];
}

- (void)requestMyFriendsList {
    
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [User sharedUser].user.uId,@"userId",nil];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetFriends
                                             forParam:param
                                             delegate:self
                                            resultObj:[[MyFriendsResult alloc] init]
                                           customInfo:@"GetFriends"];
}

- (void)requestQuestionList {
    
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"all",@"wtype",
                          [User sharedUser].user.uId,@"userId",
                          @"4",@"friendId",// 无效
                          @"1",@"latitude",// 无效
                          @"1",@"longitude",// 无效
                          nil];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetTuWenList
                                             forParam:param
                                             delegate:self
                                            resultObj:[[QuestionsResult alloc] init]
                                           customInfo:@"GetTuWenList"];
}


- (void)commitGuanzhu:(NSString*)friendId isCancel:(BOOL)isCancel {
    
    //
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          friendId,@"friendId",
                          [User sharedUser].user.uId,@"userId",nil];
    
    NSString *api = nil;
    if (isCancel) {
        api = API_Unguanzhu;
    } else {
        api = API_Guanzhu;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:api
                                             forParam:param
                                             delegate:self
                                            resultObj:[[NetResultBase alloc] init]
                                           customInfo:@"Guanzhu"];
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
    _questionView.refreshDelegate = self;
    
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
    } else if ([customInfo isEqualToString:@"Guanzhu"] && result) {
        [FadePromptView showPromptStatus:result.message duration:1.0 finishBlock:^{
            //
        }];
    } else if ([customInfo isEqualToString:@"GetFriends"] && result) {
        MyFriendsResult *friendResult = (MyFriendsResult *)result;
        [[User sharedUser] saveFriends:[friendResult friendList]];
        [self requestQuestionList];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}


#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView  {
    if (_isFristRefreshing) {
        [self requestMyFriendsList];
        _isFristRefreshing = NO;
    } else {
        [self requestQuestionList];
    }
}

- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView {
    
}


#pragma mark - QuestionInfoViewCellDelegate
- (void)questionInfoViewAction:(QuestionInfoViewAction)action questionInfo:(QuestionInfo*)question userInfo:(UserInfo*)userInfo {
    
    switch (action) {
            
        case QuestionInfoViewAction_Attention:{
            [self commitGuanzhu:question.userId isCancel:NO];
            break;
        }
        case QuestionInfoViewAction_PlayAudio:
            break;
        case QuestionInfoViewAction_PlayVideo:
            break;
        case QuestionInfoViewAction_Answer:
        case QuestionInfoViewAction_ScanDetail: {
            QuestionDetailVC *vc = [[QuestionDetailVC alloc] init];
            vc.tuWenId = question.uId;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
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
