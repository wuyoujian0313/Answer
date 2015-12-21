//
//  RedPacketVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "RedPacketVC.h"

@interface RedPacketVC ()

@end

@implementation RedPacketVC


- (UIButton *)createButton:(UIImage*)image target:(id)target selector:(SEL)selector frame:(CGRect)frame {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:frame];
    
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"打赏红包"];
    
    // 2 4 8 16 32 64
    [self layoutPanelView];
}

- (void)layoutPanelView {

    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, screenWidth - 40, 2*70 + 20 + 60)];
    [panelView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:panelView];
    
    
    CGFloat buttonWidth = (screenWidth - 40 - 20)/3.0;
    CGFloat left = 0;
    CGFloat top = 0;
    for (int i = 0; i < 6; i ++ ) {
        if (i <= 2) {
            UIButton *button = [self createButton:[UIImage imageNamed:@"redPacket"] target:self selector:@selector(redPacketAction:) frame:CGRectMake(left,top, buttonWidth, 70)];
            [panelView addSubview:button];
            button.tag = i + 100;
            
            left += buttonWidth + 10;
        } else {
            if (i == 3) {
                left = 0;
                top += 70 + 20;
            }
            
            
            UIButton *button = [self createButton:[UIImage imageNamed:@"redPacket"] target:self selector:@selector(redPacketAction:) frame:CGRectMake(left,top, buttonWidth, 70)];
            button.tag = i + 100;
            [panelView addSubview:button];
            left += buttonWidth + 10;
        }
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(redPacketAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"其他金额" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [button setTag:1000];
    [button setFrame:CGRectMake(0, panelView.frame.size.height - 20, panelView.frame.size.width, 20)];
    [panelView addSubview:button];
}

- (void)redPacketAction:(UIButton*)sender {
   // NSInteger tag = sender.tag;
    // 1000
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
