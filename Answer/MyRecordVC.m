//
//  MyRecordVC.m
//  Answer
//
//  Created by wuyj on 16/1/6.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "MyRecordVC.h"
#import "NetworkTask.h"
#import "User.h"
#import "RewardListResult.h"

@interface MyRecordVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate>
@property(nonatomic,strong)UITableView          *recordTableView;
@property(nonatomic,strong)NSArray              *recordList;
@end

@implementation MyRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"交易记录"];
    
    [self layoutRecordTableView];
    [self requestRecord];
}

- (void)requestRecord {
    
    // http://122.226.44.97/tuwen_web/fundFlow/getReward?userId=32
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetReward
                                             forParam:param
                                             delegate:self
                                            resultObj:[[RewardListResult alloc] init]
                                           customInfo:@"getRecord"];
}

- (void)layoutRecordTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStylePlain];
    [self setRecordTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:12];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _recordTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_recordTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _recordTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_recordTableView setTableFooterView:view];
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"getRecord"]) {
        //
        RewardListResult *rewardInfo = (RewardListResult*)result;
        self.recordList = rewardInfo.rewards;
        
        [_recordTableView reloadData];
    }
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_recordList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"recordTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
    }
    
    RewardInfo * info = [_recordList objectAtIndex:indexPath.row];
    NSString *timeString = info.updateDate;
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:[timeString longLongValue]/1000];
    
    //
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:updateDate];
    NSString *str1 = [NSString stringWithFormat:@"%02d月",(int)comps.month];
    NSString *str2 = [NSString stringWithFormat:@"%02d日",(int)comps.day];
    
    
    //
    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.textLabel setTextColor:[UIColor colorWithHex:0x56b5f5]];
    if ([info.type isEqualToString:@"0"]) {
        //红包支付
        NSString *str = [NSString stringWithFormat:@"%@%@向'%@'打赏%@元",str1,str2,info.targetAccount,info.amount];
        cell.textLabel.text = str;
    } else if ([info.type isEqualToString:@"1"]) {
        //红包获取
        NSString *str = [NSString stringWithFormat:@"%@%@从'%@'获打赏%@元",str1,str2,info.targetAccount,info.amount];
        cell.textLabel.text = str;
    } else if ([info.type isEqualToString:@"2"]) {
        //充值
        NSString *str = [NSString stringWithFormat:@"%@%@充值%@元",str1,str2,info.amount];
        cell.textLabel.text = str;
    } else if ([info.type isEqualToString:@"3"]) {
        //提现
        NSString *str = [NSString stringWithFormat:@"%@%@向'%@'提现%@元",str1,str2,info.targetAccount,info.amount];
        cell.textLabel.text = str;
    }
    
    NSString *status = @"";
    if ([info.status isEqualToString:@"1"]) {
        status = @"成功";
    } else if ([info.status isEqualToString:@"2"]) {
        status = @"失败";
    } else if ([info.status isEqualToString:@"3"]) {
        status = @"等待付款";
    }
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.detailTextLabel setText:status];
    

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
