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
#import "QuestionsResult.h"
#import "NetworkTask.h"
#import "User.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "QuestionDetailVC.h"

@interface QuestionListVC ()<QuestionInfoViewDelegate,NetworkTaskDelegate,CLLocationManagerDelegate,MJRefreshBaseViewDelegate>
@property (nonatomic, strong) QuestionsView                 *questionView;
@property (nonatomic, strong) CLLocationManager             *locmanager;
@property (nonatomic, strong) NSNumber                      *latitude;
@property (nonatomic, strong) NSNumber                      *longitude;
@property (nonatomic, assign) BOOL                          firstLocation;
@property (nonatomic, strong) NSTimer                       *timer;
@property (nonatomic, copy) NSString                        *guanzhuFriendId;
@property(nonatomic,assign)NSInteger                        more;
@end

@implementation QuestionListVC

-(void)dealloc {
    [_timer invalidate];
    if (_type == PageType_NearbyQuestionList) {
        [_locmanager stopUpdatingLocation];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutQuestionView];
    _firstLocation = YES;
    _more = 1;
    
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
        __weak QuestionListVC *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf beginGPS];
        });
        
        //设置定时检测，5分钟调用一次接口
        self.timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(refreshLocation) userInfo:nil repeats:YES];
        
    } else if (_type == PageType_AtMeQuestionList) {
        [self setNavTitle:@"@我的问题"];
        [_questionView beginRefreshing];
    } else  {
        [self setNavTitle:@"问题列表"];
        [_questionView beginRefreshing];
    }
}

- (void)reloadQuestionView {
    [_questionView reloadQuestionView];
}

- (void)refreshLocation {
    [_questionView beginRefreshing];
}

-(void)popBack {
    [_timer invalidate];
    [super popBack];
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"注意" message:@"您的定位服务并未打开，请到设置面板中打开图问圈的定位服务功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
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

- (void)commitGuanzhu:(NSString*)friendId {
    
    //
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          friendId,@"friendId",
                          [User sharedUser].user.uId,@"userId",nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_Guanzhu
                                             forParam:param
                                             delegate:self
                                            resultObj:[[NetResultBase alloc] init]
                                           customInfo:@"Guanzhu"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    double userLatitude = newLocation.coordinate.latitude;
    double userLongitude = newLocation.coordinate.longitude;
    NSLog(@"latitude %f, longitude %f", userLatitude, userLongitude);
    
    self.latitude = [NSNumber numberWithDouble:userLatitude];
    self.longitude = [NSNumber numberWithDouble:userLatitude];
    
    if (_firstLocation) {
        [_questionView beginRefreshing];
        _firstLocation = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [_locmanager stopUpdatingLocation];
                break;
            case kCLErrorLocationUnknown:
                [_locmanager stopUpdatingLocation];
                break;
            default:
                break;
        }
    }
}




#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"GetTuWenList"] && result) {
        
        QuestionsResult *qResult = (QuestionsResult*)result;
        [_questionView addQuestionsResult:qResult];
    } else if ([customInfo isEqualToString:@"Guanzhu"]) {
        [[User sharedUser] addFriend:_guanzhuFriendId];
        //
        [self reloadQuestionView];
        [FadePromptView showPromptStatus:@"关注成功" duration:1.0 finishBlock:^{
            
        }];
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
    if ([refreshView viewType] == MJRefreshViewTypeHeader) {
        _more = 1;
    } else if ([refreshView viewType] == MJRefreshViewTypeFooter){
        _more ++;
    }
    [self requestQuestionList];
}

- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView {
    
}

#pragma mark - QuestionTableViewCellDelegate
- (void)questionInfoViewAction:(QuestionInfoViewAction)action questionInfo:(QuestionInfo*)question userInfo:(UserInfo*)userInfo {
    
    switch (action) {
            
        case QuestionInfoViewAction_Attention:{
            [self commitGuanzhu:question.userId];
            break;
        }
        case QuestionInfoViewAction_PlayAudio:
            self.audioURL = [NSURL URLWithString:question.mediaURL];
            [self playReordFile];
            
            break;
        case QuestionInfoViewAction_PlayVideo:
            self.videoURL = [NSURL URLWithString:question.mediaURL];
            [self playVideo];
            
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
