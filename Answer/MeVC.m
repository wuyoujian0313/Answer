//
//  MeVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "MeVC.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "MyFriendsVC.h"
#import "MyWalletVC.h"
#import "LineView.h"
#import "User.h"
#import "SetVC.h"
#import "MyWalletVC.h"
#import "QuestionListVC.h"

@interface MeVC ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView          *meTableView;
@property(nonatomic,strong)UIImageView          *headImageView;
@property(nonatomic,strong)UILabel              *userNicknameLabel;
@end

@implementation MeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutMeTableView];
}

- (void)layoutMeTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight - 49) style:UITableViewStylePlain];
    [self setMeTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBounces:NO];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:105];
    [self setTableViewFooterView:0];
}

-(void)loadHeadImageAndNickName {
    
    _userNicknameLabel.text = [User sharedUser].user.nickName ? [User sharedUser].user.nickName : [User sharedUser].user.phoneNumber;
    //从缓存取
    //取图片缓存
    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    [User sharedUser].user.headImage = @"http://img.idol001.com/middle/2015/06/03/9e9b4afaa9228f72890749fe77dcf48b1433311330.jpg";
    NSString *imageUrl  = [User sharedUser].user.headImage;
    UIImage *default_image = [imageCache imageFromDiskCacheForKey:imageUrl];
    
    if (default_image == nil) {
        default_image = [UIImage imageNamed:@"defaultHeadImage"];
        
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                          placeholderImage:default_image
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     if (image) {
                                         _headImageView.image = image;
                                         [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
                                     }
                                 }
         ];
    } else {
        _headImageView.image = default_image;
    }
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _meTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 75, 75)];
    self.headImageView = imageView;
    imageView.clipsToBounds = YES;
//    [imageView.layer setCornerRadius:75/2.0];
    [view addSubview:imageView];
    
    CGFloat left = 10;
    left += 75 + 10;
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 25, _meTableView.frame.size.width, 16)];
    [self setUserNicknameLabel:nickNameLabel];
    nickNameLabel.backgroundColor = [UIColor clearColor];
    nickNameLabel.font = [UIFont systemFontOfSize:16];
    nickNameLabel.textColor = [UIColor colorWithHex:0x666666];
    [view addSubview:nickNameLabel];
    
    nickNameLabel.text = [User sharedUser].user.nickName ? [User sharedUser].user.nickName : [User sharedUser].user.phoneNumber;
    CGSize sizeText = [nickNameLabel.text sizeWithFontCompatible:nickNameLabel.font];
    left += 10 + sizeText.width;
    [_meTableView setTableHeaderView:view];
    
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 25, _meTableView.frame.size.width, 16)];
    levelLabel.backgroundColor = [UIColor clearColor];
    levelLabel.font = [UIFont systemFontOfSize:16];
    levelLabel.textColor = [UIColor redColor];
    levelLabel.text = [NSString stringWithFormat:@"%d级",[[User sharedUser].user.level intValue]];
    [view addSubview:levelLabel];
    

    left = 10 + 75 + 10;
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 60, _meTableView.frame.size.width, 16)];
    idLabel.backgroundColor = [UIColor clearColor];
    idLabel.font = [UIFont systemFontOfSize:16];
    idLabel.textColor = [UIColor grayColor];
    idLabel.text = [NSString stringWithFormat:@"ID:%@",[User sharedUser].user.uId];
    [view addSubview:idLabel];
    
    sizeText = [idLabel.text sizeWithFontCompatible:idLabel.font];
    left += sizeText.width + 10;
    
    UILabel *attentionLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 60, _meTableView.frame.size.width, 16)];
    attentionLabel.backgroundColor = [UIColor clearColor];
    attentionLabel.font = [UIFont systemFontOfSize:16];
    attentionLabel.textColor = [UIColor grayColor];
    attentionLabel.text = [NSString stringWithFormat:@"关注:%d",[[User sharedUser].user.attentionNum intValue]];
    [view addSubview:attentionLabel];
    
    sizeText = [attentionLabel.text sizeWithFontCompatible:attentionLabel.font];
    left += sizeText.width + 10;
    
    UILabel *fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 60, _meTableView.frame.size.width, 16)];
    fansLabel.backgroundColor = [UIColor clearColor];
    fansLabel.font = [UIFont systemFontOfSize:16];
    fansLabel.textColor = [UIColor grayColor];
    fansLabel.text = [NSString stringWithFormat:@"粉丝:%d",[[User sharedUser].user.fansNum intValue]];
    [view addSubview:fansLabel];
    
    [self loadHeadImageAndNickName];
}

-(void)setTableViewFooterView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _meTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_meTableView setTableFooterView:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"meTableCell";
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
            imageView.image = [UIImage imageNamed:@"myQuestion"];
            titleLabel.text = @"我的问题";
            break;
        case 1:
            imageView.image = [UIImage imageNamed:@"myPacket"];
            titleLabel.text = @"我的钱包";
            break;
        case 2:
            imageView.image = [UIImage imageNamed:@"myFriend"];
            titleLabel.text = @"我的好友";
            break;
        case 3:
            imageView.image = [UIImage imageNamed:@"setting"];
            titleLabel.text = @"设置";
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
            // 我的问题
            QuestionListVC *vc = [[QuestionListVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.type = PageType_MyQuestionList;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            
            // 我的钱包
            MyWalletVC *vc = [[MyWalletVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2: {
            // 我的好友
            MyFriendsVC *vc = [[MyFriendsVC alloc] init];
            vc.enterType = EnterType_FromMe;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3: {
            // 设置
            SetVC * vc = [[SetVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            
            
        default:
            break;
    }
}

@end
