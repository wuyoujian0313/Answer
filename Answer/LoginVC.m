//
//  LoginVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "LoginVC.h"
#import "LineView.h"
#import "NetworkTask.h"
#import "RegisterVC.h"
#import "LoginoutResult.h"
#import "AppDelegate.h"
#import "OHAttributedLabel.h"

@interface LoginVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate>

@property(nonatomic,strong)UITableView          *loginTableView;
@property(nonatomic,strong)UITextField          *nameTextField;
@property(nonatomic,strong)UITextField          *pwdTextField;
@property(nonatomic,strong)UIButton             *loginBtn;
@property(nonatomic,strong)NSIndexPath          *indexPathCell;
@end

@implementation LoginVC

-(void)dealloc {
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:@"登录"];
    [self layoutLoginTableView];
    [self layoutToRegisterView];
}

- (void)layoutToRegisterView {
    
    UIView *rootview = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 35, self.view.frame.size.width, 35)];
    rootview.backgroundColor = [UIColor clearColor];
    
    OHAttributedLabel *ohLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
    ohLabel.centerVertically = YES;
    ohLabel.automaticallyAddLinksForType = 0;
    [rootview addSubview:ohLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerAction:)];
    [rootview addGestureRecognizer:tap];
    
    NSString *noteString = @"没有账号？";
    NSString *tempString = [NSString stringWithFormat:@"%@注册图问圈账号",noteString];
    NSRange range = [tempString rangeOfString:noteString];
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:tempString];
    [attrStr setFont:[UIFont systemFontOfSize:14]];
    [attrStr setTextColor:[UIColor colorWithHex:0xff6600]];
    [attrStr modifyParagraphStylesWithBlock:^(OHParagraphStyle *paragraphStyle) {
        paragraphStyle.textAlignment = kCTTextAlignmentCenter;
    }];
    [attrStr setTextColor:[UIColor colorWithHex:0x666666] range:range];
    [attrStr setFont:[UIFont systemFontOfSize:14] range:range];
    
    CGSize size = [attrStr sizeConstrainedToSize:CGSizeMake(rootview.frame.size.width, CGFLOAT_MAX)];
    [ohLabel setFrame:CGRectMake((rootview.frame.size.width - size.width)/2.0,0, size.width, size.height)];
    ohLabel.attributedText = attrStr;
    
    [self.view addSubview:rootview];
}

- (void)layoutLoginTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-35) style:UITableViewStylePlain];
    [self setLoginTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBounces:NO];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:140];
    [self setTableViewFooterView:180];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _loginTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    CGFloat left = (_loginTableView.frame.size.width - 90)/2.0;
    CGFloat top = 45;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(left, top, 90, 75)];
    imageView.image = [UIImage imageNamed:@"login_logo"];
    [view addSubview:imageView];
    
    
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line1];
    
    [_loginTableView setTableHeaderView:view];
}


-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _loginTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0xff8915]] forState:UIControlStateNormal];
    [loginBtn.layer setCornerRadius:5.0];
    [loginBtn setTag:101];
    [loginBtn setClipsToBounds:YES];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [loginBtn setFrame:CGRectMake(11, 15, _loginTableView.frame.size.width - 22, 45)];
    [loginBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:loginBtn];
    
    
//    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [forgetBtn setBackgroundColor:[UIColor clearColor]];
//    [forgetBtn setTag:102];
//    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
//    [forgetBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [forgetBtn setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
//    [forgetBtn setFrame:CGRectMake(11, 15 + 45 + 10, _loginTableView.frame.size.width - 22, 14)];
//    [forgetBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:forgetBtn];
    
    
    [_loginTableView setTableFooterView:view];
}

-(void)registerAction:(UITapGestureRecognizer*)sender {
    // 注册
    RegisterVC *vc = [[RegisterVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)buttonAction:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    if (tag == 101) {
        // 登录
        if (_nameTextField.text == nil || [_nameTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:@"请输入手机号" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
                //
            }];
            [_nameTextField becomeFirstResponder];
            return;
        }
        
        if (_pwdTextField.text == nil || [_pwdTextField.text length] <= 0) {
            [FadePromptView showPromptStatus:@"请输入手机号" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
                //
            }];
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        [_nameTextField resignFirstResponder];
        [_pwdTextField resignFirstResponder];
        NSString *nameString = [NSString stringWithFormat:@"%@",_nameTextField.text];
        NSString *pwdString = [NSString stringWithFormat:@"%@",_pwdTextField.text];
        
//        NSDictionary* parm =[[NSDictionary alloc] initWithObjectsAndKeys:
//                             nameString,@"username",
//                             pwdString,@"password",
//                             CLIENT_ID,@"client_id",
//                             CLIENT_SECRET,@"client_secret",
//                             @"password",@"grant_type",nil];
//        
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//        [[NetworkTask sharedNetworkTask] addPOSTTaskApi:@"oauth2/access_token"
//                                               forParam:parm
//                                                  token:nil
//                                               delegate:self
//                                       receiveResultObj:[User sharedUser]
//                                             customInfo:@"login"];
        
        
        AppDelegate *app = [AppDelegate shareMyApplication];
        [app.tabController dismissViewControllerAnimated:YES completion:^{
            //
        }];
        
    }
}


-(void)keyboardWillShow:(NSNotification *)note{
    [super keyboardWillShow:note];
}

-(void)keyboardWillHide:(NSNotification *)note{
    [super keyboardWillHide:note];
    [_loginTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

-(void)keyboardDidShow:(NSNotification *)note{
    
    [super keyboardDidShow:note];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [_loginTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardBounds.size.height)];
    
    [_loginTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"login"]) {
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField  {
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _nameTextField) {
        [_pwdTextField becomeFirstResponder];
    } else if (textField == _pwdTextField){
        [textField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 不使用重用机制
    NSInteger row = [indexPath row];
    NSInteger curRow = 0;
    
    if (row == curRow) {
        static NSString *reusedCellID = @"loginCell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, cell.contentView.frame.size.width - 22, 45)];
            self.nameTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setTextAlignment:NSTextAlignmentCenter];
            [textField setClearsOnBeginEditing:YES];
            [textField setPlaceholder:@"手机号码"];
            
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"loginCell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            //
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11,0, cell.contentView.frame.size.width - 22, 45)];
            self.pwdTextField = textField;
            [textField setDelegate:self];
            [textField setSecureTextEntry:YES];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setTextAlignment:NSTextAlignmentCenter];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setClearsOnBeginEditing:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
            [textField setPlaceholder:@"请输入密码"];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45 - kLineHeight1px, cell.contentView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
