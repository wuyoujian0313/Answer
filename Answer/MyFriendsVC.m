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
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "FriendTableViewCell.h"
#import "QuestionListVC.h"
#import "MyFriendsResult.h"
#import "User.h"

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
    [self requestMyFriendsList];
}

- (void)requestMyFriendsList {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [User sharedUser].user.uId,@"userId",nil];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetFriends
                                             forParam:param
                                             delegate:self
                                            resultObj:[[MyFriendsResult alloc] init]
                                           customInfo:@"GetFriends"];
}

- (void)layoutFriendTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStylePlain];
    [self setFriendTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:12];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _friendTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_friendTableView setTableHeaderView:view];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height-kLineHeight1px, _friendTableView.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
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
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[FriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
        
        UIView *selBGView = [[UIView alloc] initWithFrame:cell.bounds];
        [selBGView setBackgroundColor:[UIColor colorWithHex:0xeeeeee]];
        cell.selectedBackgroundView = selBGView;
        
        
    }
    
    if (_enterType == EnterType_FromMe) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        [selectBtn setFrame:CGRectMake(0, 0, 50, 50)];
        [selectBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        cell.accessoryView = selectBtn;
    }
    
    UserInfo * user = [_friendList objectAtIndex:indexPath.row];
    //从缓存取
    //取图片缓存
    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    NSString *imageUrl = user.headImage;
    UIImage *default_image = [imageCache imageFromDiskCacheForKey:imageUrl];
    
    if (default_image == nil) {
        default_image = [UIImage imageNamed:@"defaultHeadImage"];
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:default_image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (image) {
                cell.imageView.image = image;
                [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
            }
        }];
    } else {
        cell.imageView.image = default_image;
    }
    
    if (user.nickName && [user.nickName length]) {
        cell.textLabel.text = user.nickName;
    } else if (user.phoneNumber && [user.phoneNumber length]) {
        cell.textLabel.text = user.phoneNumber;
    } else {
        cell.textLabel.text = @"匿名";
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QuestionListVC *vc = [[QuestionListVC alloc] init];
    vc.type = PageType_FriendQuestionList;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"GetFriends"] && result) {
        MyFriendsResult *friendResult = (MyFriendsResult *)result;
        [[User sharedUser] saveFriends:[friendResult friendList]];
        [self setFriendList:[friendResult friendList]];
        [_friendTableView reloadData];
    }
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
