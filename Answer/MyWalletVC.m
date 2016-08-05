//
//  MyWalletVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "MyWalletVC.h"
#import "MenuCollectionViewCell.h"
#import "LineView.h"
#import "RechangeVC.h"
#import "MyRecordVC.h"
#import "ToCashVC.h"
#import "MyBalanceVC.h"
#import "WithdrawVC.h"


@interface MyWalletVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView          *mainMenuView;
@property (nonatomic, strong) NSArray                   *menuData;
@end

@implementation MyWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"我的钱包"];
    [self createMenuData];
    [self layoutMenuView];
}

- (void)createMenuData {
    NSDictionary *item1 = [NSDictionary dictionaryWithObjectsAndKeys:@"rechange",@"image",@"充值",@"name", nil];
    
    NSDictionary *item2 = [NSDictionary dictionaryWithObjectsAndKeys:@"balance",@"image",@"我的余额",@"name", nil];
    
    NSDictionary *item3 = [NSDictionary dictionaryWithObjectsAndKeys:@"cash",@"image",@"提现",@"name", nil];
    
    NSDictionary *item4 = [NSDictionary dictionaryWithObjectsAndKeys:@"record",@"image",@"交易记录",@"name", nil];
    
    self.menuData = [[NSArray alloc] initWithObjects:item1,item2,item3,item4,nil];
}

- (void)layoutMenuView {
    //初始化
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 0 ;
    flowLayout.minimumLineSpacing = 0;
    
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.footerReferenceSize = CGSizeZero;
    
    
    self.mainMenuView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, self.view.frame.size.height - [DeviceInfo navigationBarHeight]) collectionViewLayout:flowLayout];
    
    [self.mainMenuView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    
    // 注册
    [_mainMenuView registerClass:[MenuCollectionViewCell class] forCellWithReuseIdentifier:MenuCollectionViewIdentifier];
    _mainMenuView.backgroundColor = [UIColor whiteColor];
    _mainMenuView.showsVerticalScrollIndicator = NO;
    _mainMenuView.showsHorizontalScrollIndicator = NO;
    _mainMenuView.delegate = self;
    _mainMenuView.dataSource = self;
    _mainMenuView.bounces = YES;
    _mainMenuView.scrollEnabled = NO;
    
    [self.view addSubview:_mainMenuView];
}


#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个分区上的元素个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 33;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, collectionView.frame.size.width, 40)];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 40- kLineHeight1px, headerView.frame.size.width, kLineHeight1px)];
    [headView addSubview:line];
    
    [headerView addSubview:headView];
    return headerView;
}


//设置元素内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = MenuCollectionViewIdentifier;
    MenuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    [cell sizeToFit];
    cell.indexPath = indexPath;
    if (indexPath.row < 4) {
        [cell setImageName:[[_menuData objectAtIndex:indexPath.row] objectForKey:@"image"] withName:[[_menuData objectAtIndex:indexPath.row] objectForKey:@"name"]];
    } else {
        [cell setImageName:nil withName:nil];
    }
    
    
    return cell;
}

//
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets top = {0,0,0,0};
    return top;
}

//设置元素大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([DeviceInfo screenWidth]/3.0,100);
}


//点击元素触发事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        //充值
        RechangeVC *vc = [[RechangeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        //余额
        MyBalanceVC *vc = [[MyBalanceVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 2) {
        //提现
        WithdrawVC *vc = [[WithdrawVC alloc] init];
        //ToCashVC *vc = [[ToCashVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 3) {
        //提现
        MyRecordVC *vc = [[MyRecordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
