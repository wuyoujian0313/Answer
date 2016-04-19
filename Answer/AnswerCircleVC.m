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
#import "QuestionsResult.h"
#import "NetworkTask.h"
#import "User.h"
#import "QuestionDetailVC.h"
#import "MyFriendsResult.h"

@interface AnswerCircleVC ()<QuestionInfoViewDelegate,NetworkTaskDelegate,MJRefreshBaseViewDelegate>
@property(nonatomic,strong)QuestionsView                *questionView;
@property(nonatomic,copy)NSString                       *guanzhuFriendId;
@property(nonatomic,assign)NSInteger                    more;
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
    _more = 1;
    
    [self requestMyFriendsList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadQuestionView)
                                                 name:NotificationChangeUserInfo
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadQuestionView)
                                                 name:NotificationGuanzhu
                                               object:nil];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewQuestionNotification)
                                                 name:NotificationAddNewQuestion
                                               object:nil];
    
}


-(void)reloadQuestionView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_questionView reloadQuestionView];
    });
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

- (void)addNewQuestionNotification {
    [_questionView clearTableViewData];
    [self requestQuestionList];
}

- (void)requestQuestionList {
    
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"all",@"wtype",
                          [NSString stringWithFormat:@"%ld",(long)_more],@"more",
                          [User sharedUser].user.uId,@"userId",
                          @"1",@"longitude",// 无效
                          @"1",@"friendId",// 无效
                          @"1",@"latitude",// 无效
                          @"1",@"longitude",// 无效
                          nil];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetTuWenList
                                             forParam:param
                                             delegate:self
                                            resultObj:[[QuestionsResult alloc] init]
                                           customInfo:@"GetTuWenList"];
}

- (void)commitGuanzhu:(NSString*)friendId {
    
    //
    self.guanzhuFriendId = friendId;
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
    self.questionView = [[QuestionsView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, screenWidth, screenHeight - navigationBarHeight - 49) delegate:self];
    _questionView.refreshDelegate = self;
    
    [self.view addSubview:_questionView];
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
        [_questionView addQuestionsResult:qResult];
        
    } else if ([customInfo isEqualToString:@"GetFriends"] && result) {
        MyFriendsResult *friendResult = (MyFriendsResult *)result;
        
        NSArray *friendIds = [[friendResult friendList] valueForKey:@"uId"];
        
        [[User sharedUser] saveFriends:friendIds];
        [_questionView beginRefreshing];
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
        if ([customInfo isEqualToString:@"GetFriends"]) {
            [_questionView beginRefreshing];
        }
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


#pragma mark - QuestionInfoViewCellDelegate
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
        case QuestionInfoViewAction_Sharing: {
          
            [self shareMenu];
            
            break;
        }
            
        case QuestionInfoViewAction_RedPackage:
            break;
        case QuestionInfoViewAction_Location:
            break;
            
        default:
            break;
    }
    
}


@end
