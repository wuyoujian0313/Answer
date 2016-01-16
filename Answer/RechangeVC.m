//
//  RechangeVC.m
//  Answer
//
//  Created by wuyj on 16/1/6.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "RechangeVC.h"
#import "RechangeTableViewCell.h"

@interface RechangeVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
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
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStylePlain];
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


- (void)createRechangeMethods {
    NSMutableDictionary *item1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"rechange",@"image",@"微信支付",@"title",@"推荐已安装微信客户端的用户使用",@"subTitle",@YES,@"seleted", nil];
    
    NSMutableDictionary *item2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"balance",@"image",@"支付宝支付",@"title",@"推荐已安装支付宝客户端的用户使用",@"subTitle",@YES,@"seleted", nil];
    
    self.rechangeMethods = [[NSArray alloc] initWithObjects:item1,item2,nil];
}

- (void)navBarAction:(UIBarButtonItem*)sender {
    [_rechangeTextField resignFirstResponder];
}

- (void)rechangeAction:(UIButton*)sender {
    
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
