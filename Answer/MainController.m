//
//  MainController.m
//  Answer
//
//  Created by wuyj on 15/12/21.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "MainController.h"
#import "AnswerCircleVC.h"
#import "DiscoverVC.h"
#import "QuestionVC.h"
#import "MessageVC.h"
#import "MeVC.h"
#import "LoginVC.h"

@interface MainController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) UIViewController              *rootVC;
@property (nonatomic, strong) UITabBarController            *homeVC;
@property (nonatomic, strong) WYJNavigationController       *loginNav;
@end

@implementation MainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupRootVC];
    [self switchToLoginVCFrom:_rootVC];
}

- (void)setupRootVC {
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor whiteColor];
    self.rootVC = rootVC;
    [self addChildViewController:_rootVC];
}

- (void)switchToHomeVC {
    [self setupTabController];
    [self.view addSubview:_homeVC.view];
    [self transitionFromViewController:_loginNav toViewController:_homeVC duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        //
        [_loginNav removeFromParentViewController];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)switchToLoginVC {
    [self switchToLoginVCFrom:_homeVC];
}

- (void)switchToLoginVCFrom:(UIViewController*)fromVC {
    [self setupLoginVC];
    [self.view addSubview:_loginNav.view];
    [self transitionFromViewController:fromVC toViewController:_loginNav duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        //
        [_homeVC removeFromParentViewController];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)setupLoginVC {
    LoginVC *controller = [[LoginVC alloc] init];
    WYJNavigationController *loginNav = [[WYJNavigationController alloc] initWithRootViewController:controller];
    self.loginNav = loginNav;
    [self addChildViewController:_loginNav];
    
}

- (void)setupTabController {
    
    self.homeVC = [[UITabBarController alloc] init];
    [_homeVC.tabBar setBarTintColor:[UIColor lightTextColor]];
    [_homeVC.tabBar setTintColor:[UIColor colorWithHex:0x12b8f6]];
    [_homeVC setDelegate:self];
    
    AnswerCircleVC * answerVC = [[AnswerCircleVC alloc] init];
    UITabBarItem * itemObj1 = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                            image:[UIImage imageNamed:@"tabbar_home"]
                                                    selectedImage:nil];
    [itemObj1 setTag:0];
    [answerVC setTabBarItem:itemObj1];
    
    DiscoverVC * discoverVC = [[DiscoverVC alloc] init];
    UITabBarItem * itemObj2 = [[UITabBarItem alloc] initWithTitle:@"图问圈"
                                                            image:[UIImage imageNamed:@"tabbar_circle"]
                                                    selectedImage:nil];
    [itemObj2 setTag:1];
    [discoverVC setTabBarItem:itemObj2];
    
    QuestionVC * questionVC = [[QuestionVC alloc] init];
    UITabBarItem * itemObj3 = [[UITabBarItem alloc] initWithTitle:@"发问题"
                                                            image:[UIImage imageNamed:@"tabbar_question"]
                                                    selectedImage:nil];
    [itemObj3 setTag:2];
    [questionVC setNavTitle:itemObj3.title];
    [questionVC setTabBarItem:itemObj3];
    
    MessageVC * messageVC = [[MessageVC alloc] init];
    UITabBarItem * itemObj4 = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                            image:[UIImage imageNamed:@"tabbar_message"]
                                                    selectedImage:nil];
    [itemObj4 setTag:3];
    [messageVC setTabBarItem:itemObj4];
    
    
    MeVC * meVC = [[MeVC alloc] init];
    UITabBarItem * itemObj5 = [[UITabBarItem alloc] initWithTitle:@"我"
                                                            image:[UIImage imageNamed:@"tabbar_me"]
                                                    selectedImage:nil];
    [itemObj5 setTag:4];
    [meVC setTabBarItem:itemObj5];
    
    WYJNavigationController *nav1 = [[WYJNavigationController alloc] initWithRootViewController:answerVC];
    WYJNavigationController *nav2 = [[WYJNavigationController alloc] initWithRootViewController:discoverVC];
    WYJNavigationController *nav3 = [[WYJNavigationController alloc] initWithRootViewController:questionVC];
    WYJNavigationController *nav4 = [[WYJNavigationController alloc] initWithRootViewController:messageVC];
    WYJNavigationController *nav5 = [[WYJNavigationController alloc] initWithRootViewController:meVC];
    
    [_homeVC setViewControllers:[[NSArray alloc] initWithObjects:nav1,nav2,nav3,nav4,nav5,nil]];
    [_homeVC setSelectedIndex:0];
    
    [self addChildViewController:_homeVC];
}

- (void)setShowHomeVC {
    [_homeVC setSelectedIndex:0];
}

#pragma UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
