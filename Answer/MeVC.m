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
    _userNicknameLabel.text = [NSString stringWithFormat:@"%@",@"帅到掉渣的老武"];
    
    //从缓存取
    //取图片缓存
    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    [User sharedUser].headImage = @"http://img.idol001.com/middle/2015/06/03/9e9b4afaa9228f72890749fe77dcf48b1433311330.jpg";
    NSString *imageUrl  = [User sharedUser].headImage;
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + 75 + 10, 25, _meTableView.frame.size.width, 16)];
    [self setUserNicknameLabel:titleLabel];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor colorWithHex:0x666666];
    [view addSubview:titleLabel];
    
    titleLabel.text = [User sharedUser].nickName;
    [_meTableView setTableHeaderView:view];
    
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
