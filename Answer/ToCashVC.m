//
//  ToCashVC.m
//  Answer
//
//  Created by wuyj on 16/1/6.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "ToCashVC.h"
#import "User.h"
#import "RechangeTableViewCell.h"
#import "NetworkTask.h"

@interface ToCashVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,NetworkTaskDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView                   *balanceTableView;
@property (nonatomic, strong) UITextField                   *rechangeTextField;
@property (nonatomic, strong) UITextField                   *acountTextField;
@property (nonatomic, strong) UINavigationBar               *navBar;
@property (nonatomic, strong) NSArray                       *rechangeMethods;
@property (nonatomic, assign) NSInteger                     selIndex;
@property (nonatomic, strong) NSIndexPath                   *currentFieldIndex;

@end

@implementation ToCashVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"提现"];
    [self createRechangeMethods];
    [self layoutBalanceTableView];
    [self layoutNavBarView];
}

- (void)createRechangeMethods {
    NSMutableDictionary *item1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"weixin",@"image",@"微信提现",@"title",@YES,@"seleted", nil];
    
//    NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"zhifubao",@"image",@"支付宝提现",@"title",@NO,@"seleted", nil];
    
    self.rechangeMethods = [[NSArray alloc] initWithObjects:item1,nil];
    _selIndex = 0;
}

- (void)layoutNavBarView {
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, screenHeight, self.view.frame.size.width, 44)];
    [_navBar setBackgroundColor:[UIColor whiteColor]];
    [_navBar setHidden:YES];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    //把导航栏集合添加到导航栏中，设置动画关闭
    [_navBar pushNavigationItem:navItem animated:NO];
    
    UIBarButtonItem *rightButton = [self configBarButtonWithTitle:@"确定" target:self selector:@selector(navBarAction:)];
    [navItem setRightBarButtonItem:rightButton];
    
    [self.view addSubview:_navBar];
}


- (void)layoutBalanceTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStyleGrouped];
    [self setBalanceTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    [self setTableViewHeaderView:62];
    [self setTableViewFooterView:80];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _balanceTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 12, view.frame.size.width, height - 24)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [view addSubview:whiteView];
    
    UILabel *labelValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, height -24)];
    labelValue.backgroundColor = [UIColor whiteColor];
    labelValue.font = [UIFont systemFontOfSize:14];
    labelValue.textColor = [UIColor colorWithHex:0x666666];
    labelValue.text = @"当前余额";
    [whiteView addSubview:labelValue];
    
    UILabel *balanceValue = [[UILabel alloc] initWithFrame:CGRectMake(90, 4, whiteView.frame.size.width - 100, 30)];
    balanceValue.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:26], NSForegroundColorAttributeName:[UIColor colorWithHex:0xff8915] };
    
    NSDictionary *attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:0xff8915] };
    
    NSString *str1 = [User sharedUser].account.balance;
    if (str1 == nil || [str1 length] == 0) {
        str1 = @"100.00";
    }
    NSString *str2 = @"元";
    NSString *str = [NSString stringWithFormat:@"%@%@",str1,str2];
    NSRange range1 = [str rangeOfString:str1];
    NSRange range2 = [str rangeOfString:str2];
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str];
    [att1 addAttributes:attributes1 range:range1];
    [att1 addAttributes:attributes2 range:range2];
    balanceValue.attributedText = att1;
    [whiteView addSubview:balanceValue];
    
    [_balanceTableView setTableHeaderView:view];
}


-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _balanceTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];

    UIButton *cashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cashBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0xff8915]] forState:UIControlStateNormal];
    [cashBtn.layer setCornerRadius:5.0];
    [cashBtn setClipsToBounds:YES];
    [cashBtn setTitle:@"提现" forState:UIControlStateNormal];
    [cashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cashBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cashBtn setFrame:CGRectMake(10,30, view.frame.size.width - 20, 40)];
    [cashBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cashBtn];

    [_balanceTableView setTableFooterView:view];
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
    
    
    [_balanceTableView setFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - keyboardBounds.size.height - 44 - navigationBarHeight)];
    
    [_balanceTableView scrollToRowAtIndexPath:_currentFieldIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    
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
    
    [_balanceTableView setFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight)];
    
    [UIView commitAnimations];
}


- (void)navBarAction:(UIBarButtonItem*)sender {
    [_rechangeTextField resignFirstResponder];
    [_acountTextField resignFirstResponder];
}

- (void)buttonAction:(UIButton*)sender {
    
    
    NSString *msg = [NSString stringWithFormat:@"您确定提现到这个微信账号：%@",_acountTextField.text];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提现"
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
    [alertView show];
    
}

- (void)requestToCash {
    
    //// http://localhost:8080/tuwen_web/fundFlow/withdrawCash?userId=32&targetAccount=23334@12.com&amount=100.31
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    
    if (_acountTextField.text) {
        [param setObject:_acountTextField.text forKey:@"targetAccount"];
    }
    
    if (_rechangeTextField.text) {
        CGFloat balance = [[User sharedUser].account.balance floatValue];
        CGFloat toCash = [_rechangeTextField.text floatValue];
        if (toCash > balance) {
            [FadePromptView showPromptStatus:@"提现金额不能大于账号余额" duration:2.0 finishBlock:^{
                //
                [_rechangeTextField becomeFirstResponder];
                
            }];
            
            return ;
        }
        [param setObject:_rechangeTextField.text forKey:@"amount"];
    }
    

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_ToCash
                                             forParam:param
                                             delegate:self
                                            resultObj:[[NetResultBase alloc] init]
                                           customInfo:@"ToCash"];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self requestToCash];
    }
}

#pragma mark - NetworkTaskDelegate

-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"ToCash"] && result) {
        [FadePromptView showPromptStatus:@"提现成功，我们会在1-3个工作日汇款，请勿重复提现" duration:2.0 finishBlock:^{
            //
        }];
    }
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}



#pragma mark - UITableViewDelegate

- (void)selectButtonAction:(UIButton*)sender event:(UIEvent*)event {
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    
    CGPoint currentTouchPosition = [touch locationInView:_balanceTableView];
    NSIndexPath *indexPath = [_balanceTableView indexPathForRowAtPoint:currentTouchPosition];
    
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
    
    [_balanceTableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [_rechangeMethods count];
    }
    
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
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
        cell.textLabel.textColor = [UIColor colorWithHex:0x666666];
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        
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
    } else {
        
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"rechangeTableCell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel *labelValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
                labelValue.backgroundColor = [UIColor whiteColor];
                labelValue.font = [UIFont systemFontOfSize:14];
                labelValue.textColor = [UIColor colorWithHex:0x666666];
                labelValue.text = @"提现账号";
                [cell.contentView addSubview:labelValue];
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 0, tableView.frame.size.width - 100, 50)];
                self.acountTextField = textField;
                [textField setDelegate:self];
                [textField setFont:[UIFont systemFontOfSize:14]];
                [textField setReturnKeyType:UIReturnKeyNext];
                [textField setClearButtonMode:UITextFieldViewModeAlways];
                [textField setClearsOnBeginEditing:YES];
                textField.placeholder = @"请输入提现到账的微信号";
                [textField setKeyboardType:UIKeyboardTypeDefault];
                [cell.contentView addSubview:textField];
                
                LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
                [cell.contentView addSubview:line];
            }
            
            return cell;
        } else if (indexPath.row == 1) {
            
            static NSString *cellIdentifier = @"rechangeTableCell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel *labelValue = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 50)];
                labelValue.backgroundColor = [UIColor whiteColor];
                labelValue.text = @"提现金额";
                labelValue.font = [UIFont systemFontOfSize:14];
                labelValue.textColor = [UIColor colorWithHex:0x666666];
                [cell.contentView addSubview:labelValue];
                
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(90, 0, tableView.frame.size.width - 100, 50)];
                [textField setDelegate:self];
                self.rechangeTextField = textField;
                [textField setKeyboardType:UIKeyboardTypeNumberPad];
                textField.placeholder = @"请输入提现金额(最大金额100元)";
                [textField setFont:[UIFont systemFontOfSize:14]];
                [textField setReturnKeyType:UIReturnKeyNext];
                [textField setClearButtonMode:UITextFieldViewModeAlways];
                [textField setClearsOnBeginEditing:YES];
                [cell.contentView addSubview:textField];
                
                LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
                [cell.contentView addSubview:line];
            }
            return cell;
            
        }
        
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        static NSString *headerIdentifier = @"headerIdentifier";
        
        UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if (headerView == nil) {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
            [headerView setBackgroundColor:[UIColor whiteColor]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width - 20, 40)];
            [label setBackgroundColor:[UIColor whiteColor]];
            [label setText:@"选择提现方式"];
            [label setFont:[UIFont systemFontOfSize:14]];
            [label setTextColor:[UIColor colorWithHex:0x666666]];
            [headerView addSubview:label];
            
            LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - kLineHeight1px, headerView.frame.size.width, kLineHeight1px)];
            [headerView addSubview:line];
            
        }
        
        return headerView;
    } else {
        static NSString *headerIdentifier = @"headerIdentifier1";
        
        UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        if (headerView == nil) {
            headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 12)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            
            LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height - kLineHeight1px, headerView.frame.size.width, kLineHeight1px)];
            [headerView addSubview:line];
            
        }
        
        return headerView;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.0;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _acountTextField) {
        self.currentFieldIndex = [NSIndexPath indexPathForRow:0 inSection:1];
    } else if (textField == _rechangeTextField) {
        self.currentFieldIndex = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _acountTextField) {
        [_acountTextField resignFirstResponder];
        [_rechangeTextField becomeFirstResponder];
        self.currentFieldIndex = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *textString = [NSMutableString stringWithString:textField.text];
    [textString replaceCharactersInRange:range withString:string];
    
    if (textField == _rechangeTextField) {
        if ([textString length] > 3) {
            [FadePromptView showPromptStatus:@"最大金额999元" duration:1.0 finishBlock:^{
                //
                [textField becomeFirstResponder];
            }];
            
            return NO;
        }
        
    }
    
    
    return YES;
}

@end
