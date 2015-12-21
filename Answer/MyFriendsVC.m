//
//  MyFriendsVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "MyFriendsVC.h"
#import "LineView.h"
#import "MyFriendsResult.h"
#import "NetworkTask.h"

@interface MyFriendsVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate>
@property(nonatomic,strong)UITableView          *friendTableView;
@property(nonatomic,strong)NSArray              *friendList;
@end

@implementation MyFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_enterType == EnterType_FromMe) {
        [self setNavTitle:@"我的好友"];
    } else {
        [self setNavTitle:@"指定好友"];
    }
    
    [self layoutFriendTableView];
}

- (void)layoutFriendTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStylePlain];
    [self setFriendTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    //[self setTableViewHeaderView:0];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _friendTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_friendTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _friendTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_friendTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_friendList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"friendTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
    }
    
    if (_enterType == EnterType_FromMe) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //cell.imageView =
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
