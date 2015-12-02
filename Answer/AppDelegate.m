//
//  AppDelegate.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "AppDelegate.h"
#import "AnswerCircleVC.h"
#import "DiscoverVC.h"
#import "QuestionVC.h"
#import "MessageVC.h"
#import "MeVC.h"

@interface AppDelegate ()<UITabBarControllerDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupVCs];
    return YES;
}

- (void)setupVCs {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    [tabController.tabBar setBarTintColor:[UIColor lightTextColor]];
    [tabController.tabBar setTintColor:[UIColor blackColor]];
    [tabController setDelegate:self];
    
    AnswerCircleVC * answerVC = [[AnswerCircleVC alloc] init];
    UITabBarItem * itemObj1 = [[UITabBarItem alloc] initWithTitle:@"图问圈"
                                                            image:[UIImage imageNamed:@"circle-default"]
                                                    selectedImage:[UIImage imageNamed:@"circle-press"]];
    [itemObj1 setTag:0];
    [answerVC setNavTitle:itemObj1.title];
    [answerVC setTabBarItem:itemObj1];
    
    DiscoverVC * discoverVC = [[DiscoverVC alloc] init];
    UITabBarItem * itemObj2 = [[UITabBarItem alloc] initWithTitle:@"发现"
                                                            image:[UIImage imageNamed:@"discover-default"]
                                                    selectedImage:[UIImage imageNamed:@"discover-press"]];
    [itemObj2 setTag:1];
    [discoverVC setNavTitle:itemObj2.title];
    [discoverVC setTabBarItem:itemObj2];
    
    QuestionVC * questionVC = [[QuestionVC alloc] init];
    UITabBarItem * itemObj3 = [[UITabBarItem alloc] initWithTitle:@"图问"
                                                            image:[UIImage imageNamed:@"question-default"]
                                                    selectedImage:[UIImage imageNamed:@"question-press"]];
    [itemObj3 setTag:2];
    [questionVC setNavTitle:itemObj3.title];
    [questionVC setTabBarItem:itemObj3];
    
    MessageVC * messageVC = [[MessageVC alloc] init];
    UITabBarItem * itemObj4 = [[UITabBarItem alloc] initWithTitle:@"消息"
                                                            image:[UIImage imageNamed:@"message-default"]
                                                    selectedImage:[UIImage imageNamed:@"message-press"]];
    [itemObj4 setTag:2];
    [messageVC setNavTitle:itemObj4.title];
    [messageVC setTabBarItem:itemObj4];
    
    
    MeVC * meVC = [[MeVC alloc] init];
    UITabBarItem * itemObj5 = [[UITabBarItem alloc] initWithTitle:@"我"
                                                            image:[UIImage imageNamed:@"me-default"]
                                                    selectedImage:[UIImage imageNamed:@"me-press"]];
    [itemObj5 setTag:2];
    [meVC setNavTitle:itemObj5.title];
    [meVC setTabBarItem:itemObj5];
    
    WYJNavigationController *nav1 = [[WYJNavigationController alloc] initWithRootViewController:answerVC];
    WYJNavigationController *nav2 = [[WYJNavigationController alloc] initWithRootViewController:discoverVC];
    WYJNavigationController *nav3 = [[WYJNavigationController alloc] initWithRootViewController:questionVC];
    WYJNavigationController *nav4 = [[WYJNavigationController alloc] initWithRootViewController:messageVC];
    WYJNavigationController *nav5 = [[WYJNavigationController alloc] initWithRootViewController:meVC];
    
    [tabController setViewControllers:[[NSArray alloc] initWithObjects:nav1,nav2,nav3,nav4,nav5,nil]];
    [tabController setSelectedIndex:0];
    self.window.rootViewController = tabController;
    [_window makeKeyAndVisible];
}

#pragma UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
