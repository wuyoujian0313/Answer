//
//  RedPacketVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "RedPacketVC.h"

@interface RedPacketVC ()<UITextFieldDelegate>
@property (nonatomic,strong) UITextField *otherTextField;
@property (nonatomic,strong) UINavigationBar *navBar;

@end

@implementation RedPacketVC


- (UIButton *)createButton:(UIImage*)image target:(id)target selector:(SEL)selector frame:(CGRect)frame {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:frame];
    
    return button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"打赏红包"];
    [self layoutPanelView];
    [self layoutNavBarView];
}

- (void)navBarAction:(UIBarButtonItem*)sender {
    
    [_otherTextField resignFirstResponder];
    if (sender.tag == 201) {
        if (_otherTextField.text == nil || [_otherTextField.text length] == 0) {
            [FadePromptView showPromptStatus:@"请输入金额(最大100)" duration:1.0 finishBlock:^{
                //
                [_otherTextField becomeFirstResponder];
            }];
        } else {
            NSInteger redNumber = [_otherTextField.text integerValue];
            if (_delegate && [_delegate respondsToSelector:@selector(setRedNumber:)]) {
                [_delegate setRedNumber:redNumber];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

- (void)redPacketAction:(UIButton*)sender {
    
    NSArray *redNumbers = @[@2,@4,@16,@32,@64,@100];
    
    NSInteger tag = sender.tag;
    if (tag != 1000) {
        // 其他金额
        NSInteger index = tag - 100;
        NSNumber *redNumber = [redNumbers objectAtIndex:index];
        if (_delegate && [_delegate respondsToSelector:@selector(setRedNumber:)]) {
            [_delegate setRedNumber:[redNumber integerValue]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        [_otherTextField setHidden:NO];
        [_otherTextField becomeFirstResponder];
    }
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
    UIBarButtonItem *leftButton = [self configBarButtonWithTitle:@"取消" target:self selector:@selector(navBarAction:)];
    leftButton.tag = 200;
    UIBarButtonItem *rightButton = [self configBarButtonWithTitle:@"确定" target:self selector:@selector(navBarAction:)];
    rightButton.tag = 201;
    
    //把导航栏集合添加到导航栏中，设置动画关闭
    [_navBar pushNavigationItem:navItem animated:NO];
    
    //把左右两个按钮添加到导航栏集合中去
    [navItem setLeftBarButtonItem:leftButton];
    [navItem setRightBarButtonItem:rightButton];
    
    [self.view addSubview:_navBar];
}

- (void)layoutPanelView {

    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(20, 160, [DeviceInfo screenWidth] - 40, 2*70 + 20 + 60 + 40)];
    [panelView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:panelView];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake((panelView.frame.size.width - 120)/2.0, 0, 140, 40)];
    self.otherTextField = textField;
    [textField setHidden:YES];
    [textField setDelegate:self];
    [textField setFont:[UIFont systemFontOfSize:14]];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setClearButtonMode:UITextFieldViewModeAlways];
    [textField setTextAlignment:NSTextAlignmentCenter];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setClearsOnBeginEditing:YES];
    [textField setPlaceholder:@"请输入金额(最大100元)"];
    [panelView addSubview:textField];
    
    
    CGFloat buttonWidth = ([DeviceInfo screenWidth] - 40 - 20)/3.0;
    CGFloat left = 0;
    CGFloat top = 40;
    for (int i = 0; i < 6; i ++ ) {
        if (i <= 2) {
            UIButton *button = [self createButton:[UIImage imageNamed:[NSString stringWithFormat:@"red%d",i]] target:self selector:@selector(redPacketAction:) frame:CGRectMake(left,top, buttonWidth, 70)];
            [panelView addSubview:button];
            button.tag = i + 100;
            
            left += buttonWidth + 10;
        } else {
            if (i == 3) {
                left = 0;
                top += 70 + 20;
            }
            
            
            UIButton *button = [self createButton:[UIImage imageNamed:[NSString stringWithFormat:@"red%d",i]] target:self selector:@selector(redPacketAction:) frame:CGRectMake(left,top, buttonWidth, 70)];
            button.tag = i + 100;
            [panelView addSubview:button];
            left += buttonWidth + 10;
        }
    }
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(redPacketAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"其他金额" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [button setTag:1000];
    [button setFrame:CGRectMake(0, panelView.frame.size.height - 40, panelView.frame.size.width, 40)];
    [panelView addSubview:button];
}



#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSMutableString *textString = [NSMutableString stringWithString:textField.text];
    [textString replaceCharactersInRange:range withString:string];
    
    if ([textString length] > 3) {
        
        [FadePromptView showPromptStatus:@"最大金额100元" duration:1.0 finishBlock:^{
            //
            [_otherTextField becomeFirstResponder];
        }];
        
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
