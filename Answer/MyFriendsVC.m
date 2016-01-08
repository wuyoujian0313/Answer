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
@property(nonatomic,strong)NSMutableArray       *friendList;
@property(nonatomic,strong)NSMutableArray       *selectFriendIds;
@property(nonatomic,strong)NSIndexPath          *selIndexPath;
@end

@implementation MyFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_enterType == EnterType_FromMe) {
        [self setNavTitle:@"我的好友"];
    } else {
        [self setNavTitle:@"@我的好友"];
        self.selectFriendIds = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    [self layoutFriendTableView];
    [self requestMyFriendsList];
}

- (void)navBarOKAction:(UIBarButtonItem*)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(setSelectedFriendIds:)]) {
        
        NSString *idsString = [_selectFriendIds componentsJoinedByString:@","];
        
        [_delegate setSelectedFriendIds:idsString];
    }
    
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

- (void)selectButtonAction:(UIButton*)sender event:(UIEvent*)event {
    
    if (_enterType == EnterType_FromPublishQuestion) {
        NSSet *touches = [event allTouches];
        UITouch *touch = [touches anyObject];
        
        CGPoint currentTouchPosition = [touch locationInView:_friendTableView];
        NSIndexPath *indexPath = [_friendTableView indexPathForRowAtPoint:currentTouchPosition];
        
        UserInfo *user = [_friendList objectAtIndex:indexPath.row];
        NSString *friendId = user.uId;
        if ([_selectFriendIds count] > 0) {
            if ([_selectFriendIds containsObject:friendId]) {
                [_selectFriendIds removeObject:friendId];
                [sender setImage:[UIImage imageNamed:@"unSelected"] forState:UIControlStateNormal];
            } else {
                [_selectFriendIds addObject:friendId];
                [sender setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
            }
        } else {
            //
            [_selectFriendIds addObject:friendId];
            [sender setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        }
        
        if ([_selectFriendIds count] > 0) {
            UIBarButtonItem *rightButton = [self configBarButtonWithTitle:@"确定" target:self selector:@selector(navBarOKAction:)];
            self.navigationItem.rightBarButtonItem = rightButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

- (void)commitUnGuanzhu:(NSString*)friendId {
    
    //
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          friendId,@"friendId",
                          [User sharedUser].user.uId,@"userId",nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_Unguanzhu
                                             forParam:param
                                             delegate:self
                                            resultObj:[[NetResultBase alloc] init]
                                           customInfo:@"Unguanzhu"];
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"GetFriends"] && result) {
        MyFriendsResult *friendResult = (MyFriendsResult *)result;
        
        NSArray *friendIds = [[friendResult friendList] valueForKey:@"uId"];
        
        [[User sharedUser] saveFriends:friendIds];
        [self setFriendList:[NSMutableArray arrayWithArray:[friendResult friendList]]];
        
        if ([_friendList count] == 0) {
            [_friendTableView setHidden:YES];
        } else {
            [_friendTableView reloadData];
        }
    } else if ([customInfo isEqualToString:@"Unguanzhu"]) {
        
        // 取消关注
        if (_selIndexPath.row < [_friendList count]) {
            
            UserInfo *user = [_friendList objectAtIndex:[_selIndexPath row]];
            [[User sharedUser] deleteFriend:user.uId];
            
            [_friendList removeObjectAtIndex:[_selIndexPath row]];
            if ([_friendList count] == 0) {
                [_friendTableView setHidden:YES];
            } else {
                [_friendTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_selIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGuanzhu object:nil];
            
        }
        
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
        [selectBtn setImage:[UIImage imageNamed:@"unSelected"] forState:UIControlStateNormal];
        [selectBtn addTarget:self action:@selector(selectButtonAction:event:) forControlEvents:UIControlEventTouchUpInside];
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //
        UserInfo * user = [_friendList objectAtIndex:indexPath.row];
        self.selIndexPath = indexPath;
        [self commitUnGuanzhu:user.uId];
        
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消关注";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_enterType == EnterType_FromMe) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        QuestionListVC *vc = [[QuestionListVC alloc] init];
        vc.type = PageType_FriendQuestionList;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
