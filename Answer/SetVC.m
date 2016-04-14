//
//  SetVC.m
//  Answer
//
//  Created by wuyj on 15/12/20.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "SetVC.h"
#import "LineView.h"
#import "AppDelegate.h"
#import "LoginoutResult.h"
#import "NetworkTask.h"
#import "User.h"
#import "AboutVC.h"

@interface SetVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate,UIActionSheetDelegate>
@property(nonatomic,strong)UITableView          *setTableView;
@end

@implementation SetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"设置"];
    [self layoutSetTableView];
}

- (void)layoutSetTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight - 49) style:UITableViewStylePlain];
    [self setSetTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBounces:NO];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:40];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _setTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_setTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _setTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_setTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"setTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, (50-30)/2.0, 30, 30)];
        imageView.tag = 100;
        [cell.contentView addSubview:imageView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(11 + 30 + 11 , 0, 200 , 50)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor colorWithHex:0x666666];
        titleLabel.tag = 101;
        titleLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:titleLabel];
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
        
        UIView *selBGView = [[UIView alloc] initWithFrame:cell.bounds];
        [selBGView setBackgroundColor:[UIColor colorWithHex:0xeeeeee]];
        cell.selectedBackgroundView = selBGView;
    }
    
    UIImageView *imageView =  (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
            imageView.image = [UIImage imageNamed:@"about"];
            titleLabel.text = @"关于图问";
            break;
        case 1:
            imageView.image = [UIImage imageNamed:@"shareToFriend"];
            titleLabel.text = @"推荐给好友";
            break;
        case 2:
            imageView.image = [UIImage imageNamed:@"logout"];
            titleLabel.text = @"退出";
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    switch (row) {
        case 0: {
            // 关于图问
            AboutVC *vc = [[AboutVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            // 推荐给好友
            [self shareMenu];
            break;
        }
        case 2: {
            // 退出
            
            UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"确认退出登录？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil];
            [sheet showInView:self.view];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"loginout"]) {
        [FadePromptView showPromptStatus:@"退出成功" duration:1.0 positionY:screenHeight- 300 finishBlock:^{
            //
            [[User sharedUser] clearUser];
            AppDelegate *app = [AppDelegate shareMyApplication];
            [app.mainVC switchToLoginVC];
        }];
    }
    
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                              [User sharedUser].user.uuid,@"uuid",
                              [User sharedUser].user.uId,@"uId",nil];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_Loginout
                                                 forParam:param
                                                 delegate:self
                                                resultObj:[[LoginoutResult alloc] init] customInfo:@"loginout"];
    }
}

@end
