//
//  RechangeVC.m
//  Answer
//
//  Created by wuyj on 16/1/6.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "RechangeVC.h"
#import "RechangeTableViewCell.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "WXPayResult.h"
#import "NetworkTask.h"
#import "User.h"



@interface RechangeVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate>
@property (nonatomic, strong) UITableView                   *rechangeTableView;
@property (nonatomic, strong) NSArray                       *rechangeMethods;
@property (nonatomic, strong) UINavigationBar               *navBar;
@property (nonatomic, strong) UITextField                   *rechangeTextField;
@property (nonatomic, assign) NSInteger                     selIndex;

@end

@implementation RechangeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"充值"];
    _selIndex = 0;
    [self createRechangeMethods];
    [self layoutRechangeTableView];
    [self layoutNavBarView];
}

- (void)layoutRechangeTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [DeviceInfo navigationBarHeight], self.view.frame.size.width, self.view.frame.size.height - [DeviceInfo navigationBarHeight]) style:UITableViewStylePlain];
    [self setRechangeTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:62];
    [self setTableViewFooterView:200];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rechangeTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 12, view.frame.size.width, 40)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [view addSubview:whiteView];
    
    UILabel *labelValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
    labelValue.backgroundColor = [UIColor whiteColor];
    labelValue.font = [UIFont systemFontOfSize:14];
    labelValue.textColor = [UIColor colorWithHex:0x666666];
    labelValue.text = @"充值金额";
    
    [whiteView addSubview:labelValue];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 0, whiteView.frame.size.width - 100, 40)];
    [textField setDelegate:self];
    self.rechangeTextField = textField;
    [textField setFont:[UIFont systemFontOfSize:14]];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setClearsOnBeginEditing:YES];
    [textField setPlaceholder:@"请输入金额(最大100元)"];
    [whiteView addSubview:textField];
    
    [_rechangeTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _rechangeTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *rechangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rechangeBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0x56b5f5]] forState:UIControlStateNormal];
    [rechangeBtn.layer setCornerRadius:5.0];
    [rechangeBtn setTag:101];
    [rechangeBtn setClipsToBounds:YES];
    [rechangeBtn setTitle:@"确认充值" forState:UIControlStateNormal];
    [rechangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rechangeBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [rechangeBtn setFrame:CGRectMake(10, 40, _rechangeTableView.frame.size.width - 20, 45)];
    [rechangeBtn addTarget:self action:@selector(rechangeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:rechangeBtn];
    
    [_rechangeTableView setTableFooterView:view];
}

#pragma mark - keyboard Notification
-(void)keyboardWillShow:(NSNotification *)note{
    
    [super keyboardWillShow:note];
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect containerFrame = _navBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _navBar.hidden = NO;
    _navBar.frame = containerFrame;
    
    [UIView commitAnimations];
}


-(void)keyboardWillHide:(NSNotification *)note{
    [super keyboardWillHide:note];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect containerFrame = _navBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _navBar.hidden = YES;
    
    [UIView commitAnimations];
}

- (void)layoutNavBarView {
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, [DeviceInfo screenHeight], self.view.frame.size.width, 44)];
    [_navBar setBackgroundColor:[UIColor whiteColor]];
    [_navBar setHidden:YES];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    //把导航栏集合添加到导航栏中，设置动画关闭
    [_navBar pushNavigationItem:navItem animated:NO];
    
    UIBarButtonItem *rightButton = [self configBarButtonWithTitle:@"确定" target:self selector:@selector(navBarAction:)];
    [navItem setRightBarButtonItem:rightButton];
    
    [self.view addSubview:_navBar];
}


- (void)createRechangeMethods {
    NSMutableDictionary *item1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"weixin",@"image",@"微信支付",@"title",@"推荐已安装微信客户端的用户使用",@"subTitle",@YES,@"seleted", nil];
    
//    NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"zhifubao",@"image",@"支付宝支付",@"title",@"推荐已安装支付宝客户端的用户使用",@"subTitle",@YES,@"seleted", nil];
    
    self.rechangeMethods = [[NSArray alloc] initWithObjects:item1,nil];
}

- (void)navBarAction:(UIBarButtonItem*)sender {
    [_rechangeTextField resignFirstResponder];
}


- (void)weixinPay {
    
    

    
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = @"10000100";
    request.prepayId = @"1101000000140415649af9fc314aa427";
    request.package = @"Sign=WXPay";
    request.nonceStr = @"a462b76e7436e98e0ed6e13c64b4fd1c";
    request.timeStamp = [NSDate timeIntervalSinceReferenceDate];
    request.sign = @"582282D72DD2B03AD892830965F428CB16E7A256";
    [WXApi sendReq:request];
}

- (void)alipay {
    
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"";
    NSString *seller = @"";
    NSString *privateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
//    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
//    order.productName = product.subject; //商品标题
//    order.productDescription = product.body; //商品描述
//    order.amount = [NSString stringWithFormat:@"%.2f",product.price]; //商品价格
//    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"alisdkdemo";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
}

- (void)rechangeAction:(UIButton*)sender {
    
//    appid                 "wx7a296d05150143e5";
//    appsecret             "dce5699086e990df3104052ce298f573";
//    partner            //用户商号  "1326100701";
//    userId             //用户id
//    money              //金额  （单位 分，不带小数点）
//    device_info        //设备号   非必输
//    body                 //商品描述
//    spbill_create_ip       //订单生成的机器 IP
//    fee_type=CNY        //货币类型
    
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [User sharedUser].user.uId,@"userId",
                          WeiXinSDKAppId,@"appid",
                          WeiXinSDKAppSecret,@"appsecret",
                          WeiXinBusinessNo,@"partner",
                          @"1",@"money",
                          @"WEB",@"device_info",
                          @"充值",@"body",
                          [DeviceInfo getIPAddress:YES],@"spbill_create_ip",
                          @"CNY",@"fee_type",
                          nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_WXPrePay
                                             forParam:param
                                             delegate:self
                                            resultObj:[[WXPayResult alloc] init]
                                           customInfo:@"WXPay"];
    
    
}

- (void)selectButtonAction:(UIButton*)sender event:(UIEvent*)event {
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:_rechangeTableView];
    NSIndexPath *indexPath = [_rechangeTableView indexPathForRowAtPoint:currentTouchPosition];
    
    NSMutableDictionary *oldMethod = [_rechangeMethods objectAtIndex:_selIndex];
    [oldMethod setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    
    
    _selIndex = indexPath.row;
    NSMutableDictionary *method = [_rechangeMethods objectAtIndex:_selIndex];
    NSNumber *selected = [method objectForKey:@"selected"];
    selected = [NSNumber numberWithBool:![selected boolValue]];
    if ([selected boolValue]) {
        [sender setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        
    } else {
        [sender setImage:[UIImage imageNamed:@"unSelected"] forState:UIControlStateNormal];
    }
    [method setObject:selected forKey:@"selected"];
    
    [_rechangeTableView reloadData];
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"WXPay"] && result) {
        WXPayResult *wxPay = (WXPayResult*)result;
        
        PayReq *request = [[PayReq alloc] init];
        request.partnerId =  wxPay.partnerid;
        request.prepayId = wxPay.prepayid;
        request.package = wxPay.package;
        request.nonceStr = wxPay.noncestr;
        request.timeStamp = [wxPay.timestamp intValue];
        request.sign = wxPay.sign;
        [WXApi sendReq:request];
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
    return [_rechangeMethods count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"rechangeTableCell";
    RechangeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RechangeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
    }
    
    NSDictionary *rechangeMethod = [_rechangeMethods objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[rechangeMethod objectForKey:@"image"]];
    cell.textLabel.text = [rechangeMethod objectForKey:@"title"];
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    cell.detailTextLabel.text = [rechangeMethod objectForKey:@"subTitle"];
    
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (indexPath.row == _selIndex) {
        [selectBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    } else {
        [selectBtn setImage:[UIImage imageNamed:@"unSelected"] forState:UIControlStateNormal];
    }
    
    [selectBtn addTarget:self action:@selector(selectButtonAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtn setFrame:CGRectMake(0, 0, 50, 50)];
    [selectBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    cell.accessoryView = selectBtn;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"headerIdentifier";
    
    UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (headerView == nil) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        [headerView setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 10, 40)];
        [label setBackgroundColor:[UIColor whiteColor]];
        [label setText:@"选择提现方式"];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:[UIColor colorWithHex:0x666666]];
        [headerView addSubview:label];
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - kLineHeight1px, headerView.frame.size.width, kLineHeight1px)];
        [headerView addSubview:line];
        
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *textString = [NSMutableString stringWithString:textField.text];
    [textString replaceCharactersInRange:range withString:string];
    
    if ([textString length] > 3) {
        
        [FadePromptView showPromptStatus:@"最大金额100元" duration:1.0 finishBlock:^{
            //
            [textField becomeFirstResponder];
        }];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_rechangeTextField resignFirstResponder];
}

@end
