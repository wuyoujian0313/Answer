//
//  QuestionVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionVC.h"
#import "RedPacketVC.h"

@interface QuestionVC ()

@end

@implementation QuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutFuncView];
}

- (UIButton *)createButton:(UIImage*)image target:(id)target selector:(SEL)selector frame:(CGRect)frame {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:frame];
    [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

    return button;
}

- (void)layoutFuncView {
    
    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, screenWidth - 40, 60)];
    [panelView.layer setCornerRadius:4.0];
    [panelView setBackgroundColor:[UIColor colorWithHex:0xdddddd]];
    [self.view addSubview:panelView];
    
    CGFloat buttonWidth = (screenWidth - 40 - 8)/4.0;
    
    UIButton *audioButton = [self createButton:[UIImage imageNamed:@"tabbar_home"] target:self selector:@selector(questionAction:) frame:CGRectMake(0, 0, buttonWidth, 60)];
    audioButton.tag = 100;
    [panelView addSubview:audioButton];
    
    UIButton *phontoButton = [self createButton:[UIImage imageNamed:@"tabbar_circle"] target:self selector:@selector(questionAction:) frame:CGRectMake(buttonWidth,0, buttonWidth, 60)];
    phontoButton.tag = 101;
    [panelView addSubview:phontoButton];
    
    UIButton *cameraButton = [self createButton:[UIImage imageNamed:@"tabbar_message"] target:self selector:@selector(questionAction:) frame:CGRectMake(2*buttonWidth,0, buttonWidth, 60)];
    cameraButton.tag = 102;
    [panelView addSubview:cameraButton];
    
    UIButton *videoButton = [self createButton:[UIImage imageNamed:@"tabbar_question"] target:self selector:@selector(questionAction:) frame:CGRectMake(3*buttonWidth,0, buttonWidth, 60)];
    videoButton.tag = 103;
    [panelView addSubview:videoButton];
}

- (void)questionAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (tag == 100) {
        //
    } else if (tag == 101) {
        
    } else if (tag == 102) {
        
    } else if (tag == 103) {
        RedPacketVC *vc = [[RedPacketVC alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
