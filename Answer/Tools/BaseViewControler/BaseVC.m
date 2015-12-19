//
//  BaseVC.m
//
//
//  Created by wuyj on 14-12-8.
//  Copyright (c) 2014年 伍友健. All rights reserved.
//

#import "BaseVC.h"



@interface BaseVC ()

@end

@implementation BaseVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unRegieditKeyboardNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self regieditKeyboardNotification];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight)];
    [rootView setBackgroundColor:[UIColor colorWithHex:0xebeef0]];
    [self.view addSubview:rootView];
    
    
    // 默认增加back 按钮
    [self configBackButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}


- (void)unRegieditKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)regieditKeyboardNotification {
    [self unRegieditKeyboardNotification];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - keyboard Notification
-(void)keyboardWillShow:(NSNotification *)note{}
-(void)keyboardDidShow:(NSNotification *)note{}
-(void)keyboardWillHide:(NSNotification *)note{}

-(void)didEnterBackgroundNotification:(NSNotification *)note {

    if (_currentAlertView) {
        [_currentAlertView dismissWithClickedButtonIndex:_currentAlertView.cancelButtonIndex animated:NO];
    }
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavTitle:(NSString*)title {
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.backgroundColor=[UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor colorWithHex:0x333333];
    label.text=title;
    label.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView=label;
    
    self.title = title;
}

- (void)setNavTitle:(NSString*)title titleColor:(UIColor *)color {
    UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.backgroundColor=[UIColor clearColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = color;
    label.text = title;
    label.textAlignment=NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    self.title = title;
}

#pragma mark - Config Top Bar Button
- (UIBarButtonItem*)configBackButton {
    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    self.navigationItem.leftBarButtonItem = itemBtn;

    return itemBtn;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIButton*)configRightBarButtonWithImage:(UIImage*)image selectImage:(UIImage*)selectIamge target:(id)target selector:(SEL)selector frame:(CGRect)frame {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectIamge forState:UIControlStateHighlighted];
    button.frame = frame;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return button;
}

- (UIButton*)configLeftBarButtonWithImage:(UIImage*)image selectImage:(UIImage*)selectIamge target:(id)target selector:(SEL)selector {
    
    UIButton* button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectIamge forState:UIControlStateHighlighted];
    button.frame=CGRectMake(0, 0, 24, 24);
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return button;
}

-(UIBarButtonItem*)configBarButtonWithTitle:(NSString*)title target:(id)target selector:(SEL)selector {

    UIBarButtonItem *itemBtn = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor colorWithHex:0x3f9bf2],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:15],NSFontAttributeName,nil];
    [itemBtn setTitleTextAttributes:dict forState:UIControlStateNormal];
    
    return itemBtn;
}

- (void)configRightBarButtonWithCustomView:(UIView*)aView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aView];
}

- (void)configLeftBarButtonWithCustomView:(UIView*)aView {
    self.navigationItem.leftBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:aView];
}

- (void)configTitleWithImage:(NSString*)imagename {
    UIImageView *titleimage= [[UIImageView alloc] initWithImage:[UIImage imageNamed:imagename]];
    [titleimage sizeToFit];
    self.navigationItem.titleView = titleimage;
}




@end
