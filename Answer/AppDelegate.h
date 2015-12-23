//
//  AppDelegate.h
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow          *window;
@property (nonatomic, strong) MainController    *mainVC;

+ (AppDelegate*)shareMyApplication;

@end

