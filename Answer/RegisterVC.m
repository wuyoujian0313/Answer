//
//  RegisterVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "RegisterVC.h"
#import "LineView.h"
#import "OHAttributedLabel.h"
#import "NetworkTask.h"
#import "NetResultBase.h"
#import "LoginoutResult.h"
#import "User.h"

@interface RegisterVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate>

@property(nonatomic,strong)UITableView          *registerTableView;
@property(nonatomic,strong)UITextField          *codeTextField;
@property(nonatomic,strong)UITextField          *phoneTextField;
@property(nonatomic,strong)UITextField          *pwdTextField;
@property(nonatomic,strong)UIButton             *codeBtn;
@property(nonatomic,strong)UIButton             *nextBtn;
@property(nonatomic,copy)NSString               *pwdNewString;

@property (nonatomic, assign) NSInteger             lessTime;			// 剩余时间的总秒数
@property (nonatomic, assign) CFRunLoopRef          runLoop;			// 消息循环
@property (nonatomic, assign) CFRunLoopTimerRef     timer;				// 消息循环定时器


void safeVerifyPhoneCodeCFTimerCallback(CFRunLoopTimerRef timer, void *info);
@end

@implementation RegisterVC

-(void)dealloc {
    if (_runLoop != nil && _timer != nil) {
        CFRunLoopTimerInvalidate(_timer);
        CFRunLoopRemoveTimer(_runLoop, _timer, kCFRunLoopCommonModes);
        [self setRunLoop:nil];
        [self setTimer:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"注册"];
    [self layoutRegisterTableView];
    [self layoutToLoginView];
}

- (void)layoutToLoginView {
    
    UIView *rootview = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 35, self.view.frame.size.width, 35)];
    rootview.backgroundColor = [UIColor clearColor];
    
    OHAttributedLabel *ohLabel = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
    ohLabel.centerVertically = YES;
    ohLabel.automaticallyAddLinksForType = 0;
    [rootview addSubview:ohLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginAction:)];
    [rootview addGestureRecognizer:tap];
    
    NSString *noteString = @"已有账号？";
    NSString *tempString = [NSString stringWithFormat:@"%@请登录",noteString];
    NSRange range = [tempString rangeOfString:noteString];
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:tempString];
    [attrStr setFont:[UIFont systemFontOfSize:14]];
    [attrStr setTextColor:[UIColor colorWithHex:0x56b5f5]];
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

- (void)layoutRegisterTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height- navigationBarHeight - 35) style:UITableViewStylePlain];
    [self setRegisterTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBounces:NO];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:8];
    [self setTableViewFooterView:180];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _registerTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, height - kLineHeight1px, view.frame.size.width, kLineHeight1px)];
    [view addSubview:line1];
    [_registerTableView setTableHeaderView:view];
}



-(void)setTableViewFooterView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _registerTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0xe8e8e8]] forState:UIControlStateNormal];
    [_nextBtn.layer setCornerRadius:5.0];
    [_nextBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [_nextBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_nextBtn setTag:101];
    [_nextBtn setClipsToBounds:YES];
    [_nextBtn setEnabled:NO];
    
    [_nextBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_nextBtn setFrame:CGRectMake(11, 20, _registerTableView.frame.size.width-22, 45)];
    [_nextBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_nextBtn];
    
    
    [_registerTableView setTableFooterView:view];
}

-(void)loginAction:(UITapGestureRecognizer*)sender {
    // 返回登陆
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)buttonAction:(UIButton *)sender {
    
    NSInteger tag = sender.tag;
    if (tag == 101) {
        //
        
        if (_codeTextField.text == nil || [_codeTextField.text length] <= 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
            [_codeTextField becomeFirstResponder];
            return;
        }
        
        if (_phoneTextField.text == nil || [_phoneTextField.text length] <= 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入手机号码"];
            [_phoneTextField becomeFirstResponder];
            return;
        }
        
        
        if (_pwdTextField.text == nil || [_pwdTextField.text length] <= 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入密码"];
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        
        BOOL isPhone = [_phoneTextField.text isValidateMobile];
        if (!isPhone) {
            
            [FadePromptView showPromptStatus:@"输入的不是手机号码" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
                //
            }];
            [_phoneTextField becomeFirstResponder];
            return;
        }
        
        if ([_pwdTextField.text length] < 6 || [_pwdTextField.text length] > 18) {
            [FadePromptView showPromptStatus:@"密码长度限制在6-18位" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
                //
            }];
        
            [_pwdTextField becomeFirstResponder];
            return;
        }
        
        //
        NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSString *phoneString = [NSString stringWithFormat:@"%@",_phoneTextField.text];
        [param setObject:phoneString forKey:@"phoneNumber"];
        NSString *codeString = [NSString stringWithFormat:@"%@",_codeTextField.text];
        [param setObject:codeString forKey:@"verifyCode"];
        
        NSString *pwdString = [NSString stringWithFormat:@"%@",_pwdTextField.text];
        [param setObject:pwdString forKey:@"password"];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_Register
                                                 forParam:param
                                                 delegate:self
                                                resultObj:[[LoginoutResult alloc] init] customInfo:@"register"];
        
    }
}

// 更新剩余时间
- (void)updateLessTime {
    if(_lessTime > 0) {
        NSString *lessTimeTmp = [[NSString alloc] initWithFormat:@"重新发送(%lu)", (unsigned long)_lessTime];
        [_codeBtn setTitle:lessTimeTmp forState:UIControlStateDisabled];
        [_codeBtn setTitleColor:[UIColor colorWithHex:0x669900] forState:UIControlStateDisabled];
        [_codeBtn setEnabled:NO];
    } else {
        NSString *lessTimeTmp = [[NSString alloc] initWithFormat:@"重新发送"];
        [_codeBtn setTitleColor:[UIColor colorWithHex:0xff6600] forState:UIControlStateNormal];
        [_codeBtn setTitle:lessTimeTmp forState:UIControlStateNormal];
        [_codeBtn setEnabled:YES];
    }
}

// 启动消息循环定时器
- (void)timerStart{
    // 创建消息循环定时器
    _runLoop = CFRunLoopGetCurrent();
    CFRunLoopTimerContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 1, 1.0, 0, 0,
                                  &safeVerifyPhoneCodeCFTimerCallback, &context);
    
    CFRunLoopAddTimer(_runLoop, _timer, kCFRunLoopCommonModes);
}

// 时钟回调函数
void safeVerifyPhoneCodeCFTimerCallback(CFRunLoopTimerRef timer, void *info) {
    // 剩余时间减1
    RegisterVC *registerVC = (__bridge id)info;
    
    // 时间秒数减1
    [registerVC setLessTime:[registerVC lessTime] - 1];
    
    // 更新倒计时时间
    [registerVC updateLessTime];
    
    if ([registerVC lessTime] <= 0) {
        CFRunLoopRemoveTimer([registerVC runLoop], [registerVC timer], kCFRunLoopCommonModes);
        [registerVC setRunLoop:nil];
        [registerVC setTimer:nil];
    }
}

// 获取手机验证码
- (void)phoneCodeStart:(id)sender {
    //
    NSString *codeString = [NSString stringWithFormat:@"%@",_phoneTextField.text];
    
    BOOL isPhoneNumber = [codeString isValidateMobile];
    if (!isPhoneNumber) {
        [FadePromptView showPromptStatus:@"输入的不是手机号码" duration:0.6 positionY:screenHeight- 300 finishBlock:^{
            //
        }];
        [_phoneTextField becomeFirstResponder];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetVerifyCode
                                             forParam:[NSDictionary dictionaryWithObject:codeString forKey:@"phoneNumber"]
                                             delegate:self
                                            resultObj:[[NetResultBase alloc] init] customInfo:@"registerCode"];

}


-(void)keyboardWillShow:(NSNotification *)note{
    [super keyboardWillShow:note];
}

-(void)keyboardWillHide:(NSNotification *)note{
    [super keyboardWillHide:note];
    
    [_registerTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

-(void)keyboardDidShow:(NSNotification *)note{
    
    [super keyboardDidShow:note];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [_registerTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyboardBounds.size.height)];
    
    [_registerTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"registerCode"]) {
        //
        // 设置倒计时时间
        [self setLessTime:60];
        
        // 启动倒计时
        [self timerStart];
        
    } else if ([customInfo isEqualToString:@"register"]) {
        [FadePromptView showPromptStatus:@"谢谢您，注册成功！" duration:1.0 positionY:screenHeight- 300 finishBlock:^{
            //
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];

}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _phoneTextField) {
        [_codeTextField becomeFirstResponder];
    } else if(textField == _codeTextField) {
        [_pwdTextField becomeFirstResponder];
    } else if (textField == _pwdTextField){
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if (textField == _phoneTextField) {
        _nextBtn.enabled = NO;
        [_nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0xe8e8e8]] forState:UIControlStateNormal];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _phoneTextField) {
        NSMutableString *textString = [NSMutableString stringWithString:textField.text];
        [textString replaceCharactersInRange:range withString:string];
        if ([textString length] > 0) {
            _nextBtn.enabled = YES;
            
            [_nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0x56b5f5]] forState:UIControlStateNormal];
        } else {
            _nextBtn.enabled = NO;
            [_nextBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0xe8e8e8]] forState:UIControlStateNormal];
        }
    } else if(textField == _pwdTextField) {
        NSMutableString *textString = [NSMutableString stringWithString:textField.text];
        [textString replaceCharactersInRange:range withString:string];
        
        if ([textString length] > 18) {
            return NO;
        }
    }
    
    
    return YES;
    
}

- (void)inputChange:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    NSString *temp = [NSString stringWithFormat:@"%@",textField.text];
    if ([temp length] > 18) {
        textField.text = _pwdNewString;
        return;
    }
    
    self.pwdNewString = [NSString stringWithFormat:@"%@",textField.text];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 不使用重用机制
    NSInteger row = [indexPath row];
    NSInteger curRow = 0;
    
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCellf1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 22, 45)];
            self.phoneTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypePhonePad];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor colorWithHex:0x666666]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:@"请输入手机号码"];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 105 - 22, 45)];
            self.codeTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypeDefault];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor colorWithHex:0x666666]];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:@"请输入验证码"];
            [cell.contentView addSubview:textField];
            
            LineView *line = [[LineView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 105,0, kLineHeight1px, 45)];
            [cell.contentView addSubview:line];
            
            self.codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_codeBtn setFrame:CGRectMake(tableView.frame.size.width - 105 + 10, 0, 105 - 20, 44)];
            [_codeBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            
            [_codeBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
            [_codeBtn addTarget:self action:@selector(phoneCodeStart:) forControlEvents:UIControlEventTouchUpInside];
            [_codeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
            [cell.contentView addSubview:_codeBtn];
            
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"registerCellf3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, tableView.frame.size.width - 22, 45)];
            self.pwdTextField = textField;
            [textField setDelegate:self];
            [textField setFont:[UIFont systemFontOfSize:14]];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyNext];
            [textField setKeyboardType:UIKeyboardTypeDefault];
            //[textField setTextAlignment:NSTextAlignmentCenter];
            [textField setTextColor:[UIColor colorWithHex:0x666666]];
            [textField addTarget:self action:@selector(inputChange:) forControlEvents:UIControlEventEditingChanged];
            [textField setClearButtonMode:UITextFieldViewModeAlways];
            [textField setPlaceholder:@"请输入新密码(6-18位)"];
            [textField setClearsOnBeginEditing:YES];
            [cell.contentView addSubview:textField];
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 45-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
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
