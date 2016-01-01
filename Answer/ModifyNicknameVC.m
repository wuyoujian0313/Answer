//
//  ModifyNicknameVC.m
//
//
//  Created by wuyj on 15-12-28.
//  Copyright (c) 2015年 伍友健. All rights reserved.
//

#import "ModifyNicknameVC.h"
#import "LineView.h"
#import "User.h"
#import "NetworkTask.h"
#import "ChangeNicknameResult.h"

#define MaxNickLength           10


@interface ModifyNicknameVC () <NetworkTaskDelegate,UITextFieldDelegate>
@property(nonatomic,strong)UITextField      *nickNameFieldText;
@property(nonatomic,strong)UILabel          *remainNumLabel;
@property(nonatomic,copy)NSString           *nickNameText;
@end

@implementation ModifyNicknameVC


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"修改昵称"];
    self.view.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarHeight + 8, self.view.frame.size.width, 50)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,kLineHeight1px)];
    [bgView addSubview:line];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(11, 0, self.view.frame.size.width - 2*11, 50)];
    [textField setDelegate:self];
    self.nickNameFieldText = textField;
    [textField addTarget:self action:@selector(nickChange:) forControlEvents:UIControlEventEditingChanged];
    [textField setFont:[UIFont systemFontOfSize:14]];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField setTextColor:[UIColor colorWithHex:0x666666]];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField setPlaceholder:@"输入昵称(1-10位)"];
    [bgView addSubview:textField];
    [textField becomeFirstResponder];
    
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width,kLineHeight1px)];
    [bgView addSubview:line1];
    
    self.remainNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 60 + navigationBarHeight, self.view.frame.size.width - 22, 15)];
    _remainNumLabel.backgroundColor = [UIColor clearColor];
    _remainNumLabel.text = [NSString stringWithFormat:@"可输%d个字",MaxNickLength];
    _remainNumLabel.textColor = [UIColor colorWithHex:0xcccccc];
    _remainNumLabel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:_remainNumLabel];
}

-(void)save {
    [_nickNameFieldText resignFirstResponder];
    
    NSString *nickName = [NSString stringWithFormat:@"%@",_nickNameFieldText.text];
    NSString *temp = [nickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    temp = [temp stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (temp == nil || (temp!= nil && [temp length] == 0)) {
        [FadePromptView showPromptStatus:@"昵称不能为空" duration:1.0 finishBlock:^{
            //
            [_nickNameFieldText becomeFirstResponder];
        }];
        
        
        
        return;
    }
    
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:temp,@"nickname", [User sharedUser].user.uId,@"userId",nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_UpdateNickname
                                             forParam:param
                                             delegate:self
                                            resultObj:[[ChangeNicknameResult alloc] init]
                                           customInfo:@"modifyNickName"];
}

- (void)nickChange:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    NSString *temp = [NSString stringWithFormat:@"%@",textField.text];
    if ([temp length] > MaxNickLength ) {
        textField.text = _nickNameText;
        return;
    }
    
    self.nickNameText = [NSString stringWithFormat:@"%@",textField.text];
    if (textField.text != nil && [textField.text length] > 0) {
        
        UIBarButtonItem * rightItem = [self configBarButtonWithTitle:@"保存" target:self selector:@selector(save)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    _remainNumLabel.text = [NSString stringWithFormat:@"可输%lu个字",MaxNickLength - [textField.text length]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text != nil && [textField.text length] > 0) {
        UIBarButtonItem * rightItem = [self configBarButtonWithTitle:@"保存" target:self selector:@selector(save)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *textString = [NSMutableString stringWithString:textField.text];
    [textString replaceCharactersInRange:range withString:string];
    
    if ([textString length] > MaxNickLength) {
        return NO;
    }
    
    return YES;
}


-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"modifyNickName"]) {

        [FadePromptView showPromptStatus:@"修改成功" duration:1.0 finishBlock:^{
            //
            [_nickNameFieldText becomeFirstResponder];
            
            User *user = [User sharedUser];
            user.user.nickName = _nickNameText;
            [user saveToUserDefault];
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}

@end
