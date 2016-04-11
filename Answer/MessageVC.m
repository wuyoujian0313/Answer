//
//  MessageVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "MessageVC.h"
#import "LineView.h"
#import "SystemMessageVC.h"

@interface MessageVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView          *meassageTableView;
@property(nonatomic,strong) GetNewMsgCountResult  *msgCountRec;
@end

@implementation MessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutMessageTableView];
}

- (void)layoutMessageTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight - 49) style:UITableViewStylePlain];
    [self setMeassageTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBounces:NO];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:12];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _meassageTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_meassageTableView setTableHeaderView:view];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height-kLineHeight1px, _meassageTableView.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _meassageTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_meassageTableView setTableFooterView:view];
}

- (void)reloadData:(GetNewMsgCountResult *)msgCountRec {
    
    self.msgCountRec = msgCountRec;
    [_meassageTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"messageTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
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
        
        UIImageView * accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 50,(50-15)/2.0, 15, 15)];
        [accessoryView setImage:[UIImage imageNamed:@"red"]];
        accessoryView.tag = 102;
        accessoryView.clipsToBounds = YES;
        [accessoryView.layer setCornerRadius:7.5];
        
        [cell.contentView addSubview:accessoryView];
    }
    
    UIImageView *imageView =  (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIImageView * accessoryView = (UIImageView*)[cell.contentView viewWithTag:102];
    NSInteger row = indexPath.row;
    switch (row) {
        case 0:
            imageView.image = [UIImage imageNamed:@"answerMyQ"];
            titleLabel.text = @"回答我的问题";
            if (_msgCountRec.answerCount != nil && [_msgCountRec.answerCount length]) {
                accessoryView.hidden = NO;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            } else {
                accessoryView.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        case 1:
            imageView.image = [UIImage imageNamed:@"atMe"];
            titleLabel.text = @"@我的问题";
            if (_msgCountRec.atmecount != nil && [_msgCountRec.atmecount length]) {
                accessoryView.hidden = NO;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            } else {
                accessoryView.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        case 2:
            imageView.image = [UIImage imageNamed:@"sysMessage"];
            titleLabel.text = @"系统消息";
            if (_msgCountRec.sysMsgCount != nil && [_msgCountRec.sysMsgCount length]) {
                accessoryView.hidden = NO;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                
            } else {
                accessoryView.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
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
            if (_msgCountRec.answerCount && [_msgCountRec.answerCount length]) {
                // 回答我的问题
                SystemMessageVC *vc = [[SystemMessageVC alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.messageType = MessageType_answerMyQuestion;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            break;
        }
        case 1: {
            
            // @我的问题
            if (_msgCountRec.atmecount && [_msgCountRec.atmecount length]) {
                SystemMessageVC *vc = [[SystemMessageVC alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.messageType = MessageType_atMe;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            break;
        }
        case 2: {
            // 系统消息
            if (_msgCountRec.sysMsgCount && [_msgCountRec.sysMsgCount length]) {
                SystemMessageVC *vc = [[SystemMessageVC alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.messageType = MessageType_system;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
            break;
        }
            
        default:
            break;
    }
}

@end
