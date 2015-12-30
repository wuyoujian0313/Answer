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
    
    [self setTableViewHeaderView:190];
    [self setTableViewFooterView:0];
}

-(void)loadHeadImage {

    //从缓存取
    //取图片缓存
    SDImageCache * imageCache = [SDImageCache sharedImageCache];
    [User sharedUser].user.headImage = @"http://img.idol001.com/middle/2015/06/03/9e9b4afaa9228f72890749fe77dcf48b1433311330.jpg";
    NSString *imageUrl  = [User sharedUser].user.headImage;
    UIImage *default_image = [imageCache imageFromDiskCacheForKey:imageUrl];
    
    if (default_image == nil) {
        default_image = [UIImage imageNamed:@"defaultMeHead"];
        
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

- (UIView *)createLabelWithFrame:(CGRect)frame text:(NSString*)text value:(NSString*)value {
    
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v setBackgroundColor:[UIColor clearColor]];
    
    UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
    labelText.backgroundColor = [UIColor clearColor];
    labelText.font = [UIFont systemFontOfSize:16];
    labelText.textAlignment = NSTextAlignmentCenter;
    labelText.textColor = [UIColor grayColor];
    labelText.text = text;
    [v addSubview:labelText];
    
    UILabel *labelValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 + 5, frame.size.width, 20)];
    labelValue.backgroundColor = [UIColor clearColor];
    labelValue.font = [UIFont systemFontOfSize:16];
    labelValue.textAlignment = NSTextAlignmentCenter;
    labelValue.textColor = [UIColor grayColor];
    if (value && [value length]) {
        labelValue.text = value;
    }
    
    [v addSubview:labelValue];
    
    return v;
}

- (void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _meTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((_meTableView.frame.size.width - 75)/2.0, 15, 75, 75)];
    self.headImageView = imageView;
    imageView.clipsToBounds = YES;
    [imageView.layer setCornerRadius:75/2.0];
    [view addSubview:imageView];
    
    CGFloat left = 10;
    CGFloat top = 15 + 75 + 10;
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, _meTableView.frame.size.width - 20, 20)];
    [self setUserNicknameLabel:nickNameLabel];
    nickNameLabel.backgroundColor = [UIColor clearColor];
    nickNameLabel.font = [UIFont systemFontOfSize:16];
    nickNameLabel.textAlignment = NSTextAlignmentCenter;
    nickNameLabel.textColor = [UIColor grayColor];
    nickNameLabel.text = [[User sharedUser].user.nickName length] > 0 ? [User sharedUser].user.nickName : [User sharedUser].user.phoneNumber;
    [view addSubview:nickNameLabel];
    
    
    CGFloat w = screenWidth / 4.0;
    top += 20 + 10;
    left = 0;
    UIView *idView = [self createLabelWithFrame:CGRectMake(left, top, w, 45) text:@"ID" value:[User sharedUser].user.uId];
    [view addSubview:idView];
    
    left += w;
    NSString *level = @"0";
    if ([User sharedUser].user.level && [[User sharedUser].user.level length]) {
        level = [User sharedUser].user.level;
    }
    UIView *levelView = [self createLabelWithFrame:CGRectMake(left, top, w, 45) text:@"等级" value:level];
    [view addSubview:levelView];
    
    left += w;
    NSString *attentionNum = @"0";
    if ([User sharedUser].user.guanzhuCount && [[User sharedUser].user.guanzhuCount length]) {
        attentionNum = [User sharedUser].user.guanzhuCount;
    }
    UIView *attentionView = [self createLabelWithFrame:CGRectMake(left, top, w, 45) text:@"关注" value:attentionNum];
    [view addSubview:attentionView];
    
    left += w;
    NSString *fansNum = @"0";
    if ([User sharedUser].user.fansNum && [[User sharedUser].user.fansNum length]) {
        fansNum = [User sharedUser].user.fansNum;
    }
    UIView *fansView = [self createLabelWithFrame:CGRectMake(left, top, w, 45) text:@"粉丝" value:fansNum];
    [view addSubview:fansView];
    

    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, height-kLineHeight1px, _meTableView.frame.size.width, kLineHeight1px)];
    [view addSubview:line];
    
    [_meTableView setTableHeaderView:view];
    [self loadHeadImage];
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
