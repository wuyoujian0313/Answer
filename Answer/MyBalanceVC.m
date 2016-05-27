//
//  MyBalanceVC.m
//  Answer
//
//  Created by wuyj on 16/1/6.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "MyBalanceVC.h"
#import "User.h"
#import "ToCashVC.h"
#import "RechangeVC.h"

@interface MyBalanceVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView                   *balanceTableView;


@end

@implementation MyBalanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"我的余额"];
    [self layoutBalanceTableView];
}



- (void)layoutBalanceTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, self.view.frame.size.height - [DeviceInfo navigationBarHeight]) style:UITableViewStylePlain];
    [self setBalanceTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:140];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _balanceTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(10, 12, view.frame.size.width-20, height - 12)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [whiteView.layer setCornerRadius:4.0];
    [view addSubview:whiteView];
    
    UILabel *labelValue = [[UILabel alloc] initWithFrame:CGRectMake(6, 4, 60, 20)];
    labelValue.backgroundColor = [UIColor whiteColor];
    labelValue.font = [UIFont systemFontOfSize:12];
    labelValue.textColor = [UIColor colorWithHex:0x666666];
    labelValue.text = @"当前余额";
    [whiteView addSubview:labelValue];
    
    UILabel *balanceValue = [[UILabel alloc] initWithFrame:CGRectMake(6, 30, 300, 30)];
    balanceValue.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:30], NSForegroundColorAttributeName:[UIColor colorWithHex:0xff8915] };
    
    NSDictionary *attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:0xff8915] };
    
    NSString *str1 = [User sharedUser].account.balance;
    if (str1 == nil || [str1 length] == 0) {
        str1 = @"0.00";
    }
    NSString *str2 = @"元";
    NSString *str = [NSString stringWithFormat:@"%@%@",str1,str2];
    NSRange range1 = [str rangeOfString:str1];
    NSRange range2 = [str rangeOfString:str2];
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str];
    [att1 addAttributes:attributes1 range:range1];
    [att1 addAttributes:attributes2 range:range2];
    balanceValue.attributedText = att1;
    [whiteView addSubview:balanceValue];
    
    CGFloat btnWidth = (whiteView.frame.size.width - 18)/2.0;
    UIButton *cashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cashBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0xff8915]] forState:UIControlStateNormal];
    [cashBtn.layer setCornerRadius:5.0];
    [cashBtn setTag:101];
    [cashBtn setClipsToBounds:YES];
    [cashBtn setTitle:@"提现" forState:UIControlStateNormal];
    [cashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cashBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cashBtn setFrame:CGRectMake(6, whiteView.frame.size.height - 50, btnWidth, 40)];
    [cashBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:cashBtn];
    
    UIButton *rechangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rechangeBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0x56b5f5]] forState:UIControlStateNormal];
    [rechangeBtn.layer setCornerRadius:5.0];
    [rechangeBtn setTag:102];
    [rechangeBtn setClipsToBounds:YES];
    [rechangeBtn setTitle:@"充值" forState:UIControlStateNormal];
    [rechangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rechangeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rechangeBtn setFrame:CGRectMake(6 + btnWidth + 6, whiteView.frame.size.height - 50, btnWidth, 40)];
    [rechangeBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:rechangeBtn];
    
    [_balanceTableView setTableHeaderView:view];
}

- (void)buttonAction:(UIButton*)sender {
    if (sender.tag == 101) {
        ToCashVC *vc = [[ToCashVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 102) {
        RechangeVC *vc = [[RechangeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _balanceTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_balanceTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

@end
