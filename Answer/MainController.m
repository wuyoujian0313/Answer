//
//  MainController.m
//  Answer
//
//  Created by wuyj on 15/12/21.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "MainController.h"
#import <AVFoundation/AVFoundation.h>
#import "AnswerCircleVC.h"
#import "DiscoverVC.h"
#import "QuestionVC.h"
#import "MessageVC.h"
#import "MeVC.h"
#import "LoginVC.h"
#import "User.h"

#import "NetworkTask.h"
#import "GetNewMsgCountResult.h"


@interface MainController ()<UITabBarControllerDelegate,NetworkTaskDelegate>

@property (nonatomic, strong) UIViewController              *rootVC;
@property (nonatomic, strong) WYJNavigationController       *loginNav;
@property (nonatomic, strong) UITabBarController            *homeVC;
@property (nonatomic, strong) UIViewController              *currentVC;
@property (nonatomic, strong) UIViewController              *currentTabVC;
@property (nonatomic, strong) MessageVC                     *messageVC;

@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupRootVC];
    
    [[User sharedUser] loadFromUserDefault];
    if ([User sharedUser].user && [User sharedUser].user.uuid && [User sharedUser].user.uId) {
        [self switchToHomeVCFrom:_rootVC];
    } else {
        [self switchToLoginVCFrom:_rootVC];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        [session setActive:YES error:nil];
    });
}

- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return _currentVC;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return _currentVC;
}

- (void)setupRootVC {
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor whiteColor];
    self.rootVC = rootVC;
    [self addChildViewController:_rootVC];
    [_rootVC didMoveToParentViewController:self];
}

- (void)switchToHomeVC {
    [self switchToHomeVCFrom:_loginNav];
}

- (void)switchToLoginVC {
    [self switchToLoginVCFrom:_homeVC];
}

- (void)switchToHomeVCFrom:(UIViewController*)fromVC {
    [self setupTabController];
    
    [self transitionFromViewController:fromVC toViewController:_homeVC duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        //
        _currentVC = _homeVC;
        [_loginNav removeFromParentViewController];
        [_currentVC didMoveToParentViewController:self];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)switchToLoginVCFrom:(UIViewController*)fromVC {
    [self setupLoginVC];
    
    [self transitionFromViewController:fromVC toViewController:_loginNav duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        //
        _currentVC = _loginNav;
        [_homeVC removeFromParentViewController];
        [_currentVC didMoveToParentViewController:self];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)setupLoginVC {
    LoginVC *controller = [[LoginVC alloc] init];
    WYJNavigationController *loginNav = [[WYJNavigationController alloc] initWithRootViewController:controller];
    self.loginNav = loginNav;
    [self addChildViewController:_loginNav];
    [self.view addSubview:_loginNav.view];
}

- (void)setupTabController {
    
    self.homeVC = [[UITabBarController alloc] init];
    [_homeVC.tabBar setBarTintColor:[UIColor lightTextColor]];
    [_homeVC.tabBar setTintColor:[UIColor colorWithHex:0x12b8f6]];
    [_homeVC setDelegate:self];
    
    AnswerCircleVC *answerVC = [[AnswerCircleVC alloc] init];
    UITabBarItem *itemObj1 = [[UITabBarItem alloc] initWithTitle:@"图问"
                                                            image:[UIImage imageNamed:@"tabbar_home"]
                                                    selectedImage:nil];
    [itemObj1 setTag:0];
    [answerVC setTabBarItem:itemObj1];
    
    DiscoverVC *discoverVC = [[DiscoverVC alloc] init];
    UITabBarItem *itemObj2 = [[UITabBarItem alloc] initWithTitle:@"发现"
                                                            image:[UIImage imageNamed:@"tabbar_circle"]
                                                    selectedImage:nil];
    [itemObj2 setTag:1];
    [discoverVC setTabBarItem:itemObj2];
    
    QuestionVC *questionVC = [[QuestionVC alloc] init];
    UITabBarItem *itemObj3 = [[UITabBarItem alloc] initWithTitle:@"提问"
                                                            image:[UIImage imageNamed:@"tabbar_question"]
                                                    selectedImage:nil];
    [itemObj3 setTag:2];
    [questionVC setNavTitle:itemObj3.title];
    [questionVC setTabBarItem:itemObj3];
    
    self.messageVC = [[MessageVC alloc] init];
    UITabBarItem *itemObj4 = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                            image:[UIImage imageNamed:@"tabbar_message"]
                                                    selectedImage:nil];
    [itemObj4 setTag:3];
    [_messageVC setTabBarItem:itemObj4];
    
    
    MeVC *meVC = [[MeVC alloc] init];
    UITabBarItem *itemObj5 = [[UITabBarItem alloc] initWithTitle:@"我"
                                                            image:[UIImage imageNamed:@"tabbar_me"]
                                                    selectedImage:nil];
    [itemObj5 setTag:4];
    [meVC setTabBarItem:itemObj5];
    
    WYJNavigationController *nav1 = [[WYJNavigationController alloc] initWithRootViewController:answerVC];
    WYJNavigationController *nav2 = [[WYJNavigationController alloc] initWithRootViewController:discoverVC];
    WYJNavigationController *nav3 = [[WYJNavigationController alloc] initWithRootViewController:questionVC];
    WYJNavigationController *nav4 = [[WYJNavigationController alloc] initWithRootViewController:_messageVC];
    WYJNavigationController *nav5 = [[WYJNavigationController alloc] initWithRootViewController:meVC];
    
    [_homeVC setViewControllers:[[NSArray alloc] initWithObjects:nav1,nav2,nav3,nav4,nav5,nil]];
    [_homeVC setSelectedIndex:0];
    _currentTabVC = nav1;
    
    
    [self addChildViewController:_homeVC];
    [self.view addSubview:_homeVC.view];
}

- (void)setShowHomeVC {
    [_homeVC setSelectedIndex:0];
}

- (void)getNewMsgCount {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetNewMsgCount
                                             forParam:param
                                             delegate:self
                                            resultObj:[[GetNewMsgCountResult alloc] init]
                                           customInfo:@"GetNewMsgCount"];
}

#pragma UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    if (_currentTabVC != viewController) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
        
        if ([[(WYJNavigationController*)viewController topViewController] isKindOfClass:[MessageVC class]]) {
            //
            [self getNewMsgCount];
        }
        
        _currentTabVC = viewController;
    }
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    if ([customInfo isEqualToString:@"GetNewMsgCount"] && result) {
        
        [_messageVC reloadData:(GetNewMsgCountResult*)result];
    }
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
