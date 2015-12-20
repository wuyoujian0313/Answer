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
    NSDictionary *item1 = [NSDictionary dictionaryWithObjectsAndKeys:@"myQuestion",@"image",@"充值",@"name", nil];
    
    NSDictionary *item2 = [NSDictionary dictionaryWithObjectsAndKeys:@"myFriend",@"image",@"余额",@"name", nil];
    
    NSDictionary *item3 = [NSDictionary dictionaryWithObjectsAndKeys:@"myPacket",@"image",@"提现",@"name", nil];
    
    NSDictionary *item4 = [NSDictionary dictionaryWithObjectsAndKeys:@"setting",@"image",@"记录",@"name", nil];
    
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
    
    
    self.mainMenuView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) collectionViewLayout:flowLayout];
    
    [self.mainMenuView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    
    // 注册
    [_mainMenuView registerClass:[MenuCollectionViewCell class] forCellWithReuseIdentifier:MenuCollectionViewIdentifier];
    _mainMenuView.backgroundColor = [UIColor whiteColor];
    _mainMenuView.showsVerticalScrollIndicator = NO;
    _mainMenuView.showsHorizontalScrollIndicator = NO;
    _mainMenuView.delegate = self;
    _mainMenuView.dataSource = self;
    
    [self.view addSubview:_mainMenuView];
}


#pragma mark - collectionView delegate
//设置分区
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个分区上的元素个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
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
    [cell setImageName:[[_menuData objectAtIndex:indexPath.row] objectForKey:@"image"] withName:[[_menuData objectAtIndex:indexPath.row] objectForKey:@"name"]];
    
    return cell;
}

//
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets top = {0,0,0,0};
    return top;
}

//设置元素大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(screenWidth/3.0,100);
}


//点击元素触发事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
