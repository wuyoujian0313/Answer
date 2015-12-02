//
//  WYJNavigationController.m
//  FamilyNetwork
//
//  Created by wuyj on 14-12-27.
//  Copyright (c) 2014年 伍友健. All rights reserved.
//

#import "WYJNavigationController.h"

@implementation WYJNavigationController

- (void)dealloc
{
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIStatusBarStyle style = [self.topViewController preferredStatusBarStyle];
    return style;
}

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
