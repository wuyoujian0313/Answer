//
//  WithdrawVC.m
//  Answer
//
//  Created by wuyoujian on 16/8/5.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "WithdrawVC.h"

@interface WithdrawVC ()

@end

@implementation WithdrawVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNavTitle:@"提现"];
    [self setContentViewBackgroundColor:[UIColor whiteColor]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 60 + [DeviceInfo navigationBarHeight], self.view.frame.size.width - 120, self.view.frame.size.width - 120)];
    [imageView setImage:[UIImage imageNamed:@"twQRcode.jpg"]];
    [self.view addSubview:imageView];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 60 + self.view.frame.size.width-120 + [DeviceInfo navigationBarHeight], self.view.frame.size.width - 20, 40)];
    [label setText:@"截屏-在微信打开-长按识别二维码-确认登录"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
