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
    return 10;// [_friendList count];
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
    
    //从缓存取
    //取图片缓存
    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    NSString *imageUrl = @"http://img.idol001.com/middle/2015/06/03/9e9b4afaa9228f72890749fe77dcf48b1433311330.jpg";
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
    
    
    cell.textLabel.text = @"帅到掉渣的老武";
    
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
    
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
