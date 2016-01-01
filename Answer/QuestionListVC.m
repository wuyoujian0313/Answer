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
#import "QuestionsResult.h"
#import "NetworkTask.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface QuestionListVC ()<QuestionInfoViewDelegate,AVAudioPlayerDelegate,NetworkTaskDelegate,CLLocationManagerDelegate,MJRefreshBaseViewDelegate>
@property (nonatomic, strong) QuestionsView                 *questionView;
@property (nonatomic, strong) AVAudioPlayer                 *audioPlayer;
@property (nonatomic, strong) NSURL                         *recordedFile;
@property (nonatomic, copy) NSString                        *videoPathString;
@property (nonatomic, strong) MPMoviePlayerViewController   *moviePlayer;
@property (nonatomic, strong) CLLocationManager             *locmanager;
@property (nonatomic, strong) NSNumber                      *latitude;
@property (nonatomic, strong) NSNumber                      *longitude;
@end

@implementation QuestionListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutQuestionView];
    
    // Do any additional setup after loading the view.
    if (_type == PageType_FriendQuestionList) {
        [self setNavTitle:@"好友问题"];
        [_questionView beginRefreshing];
    } else if ( _type == PageType_MyQuestionList) {
        [self setNavTitle:@"我的问题"];
        [_questionView beginRefreshing];
    } else if (_type == PageType_NearbyQuestionList) {
        [self setNavTitle:@"附近问题"];
        //
        [self beginGPS];
    } else if (_type == PageType_AtMeQuestionList) {
        [self setNavTitle:@"@我的问题"];
        [_questionView beginRefreshing];
    } else  {
        [self setNavTitle:@"问题列表"];
        [_questionView beginRefreshing];
    }
}


- (void)beginGPS {
    
    if ([CLLocationManager locationServicesEnabled]&&[CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        
        self.locmanager = [[CLLocationManager alloc] init];
        [_locmanager setDelegate:self];
        [_locmanager setDesiredAccuracy:kCLLocationAccuracyBest];
        if ([_locmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locmanager requestWhenInUseAuthorization];
        }
        if ([_locmanager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locmanager requestAlwaysAuthorization];
        }
        
        [_locmanager startUpdatingLocation];
    } else {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"注意" message:@"您的定位服务并未打开，请到设置面板中打开百度移动办公定位服务功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
    }
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    double userLatitude = newLocation.coordinate.latitude;
    double userLongitude = newLocation.coordinate.longitude;
    NSLog(@"latitude %f, longitude %f", userLatitude, userLongitude);
    
    self.latitude = [NSNumber numberWithDouble:userLatitude];
    self.longitude = [NSNumber numberWithDouble:userLatitude];
    
    [_questionView beginRefreshing];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [_locmanager stopUpdatingLocation];
                break;
            case kCLErrorLocationUnknown:
                break;
            default:
                break;
        }
    }
}


- (void)requestQuestionList {
    
    
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    
    [param setValue:[User sharedUser].user.uId forKey:@"userId"];
    NSString *wtype = nil;
    if (_type == PageType_FriendQuestionList) {
        
        [param setValue:@"1" forKey:@"friendId"];//无效
        [param setValue:@"1" forKey:@"latitude"];//无效
        [param setValue:@"1" forKey:@"longitude"];//无效
        
        wtype = @"friend";
        
    } else if ( _type == PageType_MyQuestionList) {
        
        [param setValue:@"1" forKey:@"latitude"];//无效
        [param setValue:@"1" forKey:@"longitude"];//无效
        [param setValue:@"1" forKey:@"friendId"];//无效
        wtype = @"mylist";
    } else if (_type == PageType_NearbyQuestionList) {
        
        [param setValue:[_latitude stringValue] forKey:@"latitude"];
        [param setValue:[_longitude stringValue] forKey:@"longitude"];
        [param setValue:@"1" forKey:@"friendId"];//无效
        wtype = @"near";
    } else if (_type == PageType_AtMeQuestionList) {
        [param setValue:@"1" forKey:@"latitude"];//无效
        [param setValue:@"1" forKey:@"longitude"];//无效
        [param setValue:@"1" forKey:@"friendId"];//无效
        wtype = @"atme";
    } else {
        [param setValue:@"1" forKey:@"latitude"];//无效
        [param setValue:@"1" forKey:@"longitude"];//无效
        [param setValue:@"1" forKey:@"friendId"];//无效
        wtype = @"all";
    }
    
    [param setValue:wtype forKey:@"wtype"];
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
    
    BOOL haveUserView = YES;
    if ( _type == PageType_MyQuestionList) {
        haveUserView = NO;
    }

    self.questionView = [[QuestionsView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, screenWidth, screenHeight - navigationBarHeight) haveUserView:haveUserView delegate:self];
    _questionView.refreshDelegate = self;
    
    [self.view addSubview:_questionView];
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

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView  {
    [self requestQuestionList];
}

- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView {
    
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
- (void)questionInfoViewAction:(QuestionInfoViewAction)action questionInfo:(QuestionInfo*)question userInfo:(UserInfo*)userInfo {
}


@end
