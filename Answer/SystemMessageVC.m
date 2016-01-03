//
//  SystemMessageVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "SystemMessageVC.h"
#import "LineView.h"
#import "MessagesResult.h"
#import "NetworkTask.h"
#import "User.h"

@interface SystemMessageVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate,UIActionSheetDelegate>
@property(nonatomic,strong)UITableView          *messageTableView;
@property(nonatomic,strong)NSArray              *messageList;
@end

@implementation SystemMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_messageType == MessageType_atMe) {
        [self setNavTitle:@"@我的消息"];
    } else if(_messageType == MessageType_system) {
        [self setNavTitle:@"系统消息"];
    } else {
        [self setNavTitle:@"回答我的问题的消息"];
    }
    
    [self layoutMessageTableView];
    [self requestMessageList];
}

- (void)requestMessageList {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    if (_messageType == MessageType_atMe) {
        [param setObject:@"atme" forKey:@"wtype"];
    } else if(_messageType == MessageType_system) {
        [param setObject:@"sys" forKey:@"wtype"];
    } else {
        [param setObject:@"mylist" forKey:@"wtype"];
    }
    
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetSystemMessage
                                             forParam:param
                                             delegate:self
                                            resultObj:[[MessagesResult alloc] init]
                                           customInfo:@"GetSystemMessage"];
}

- (void)navBarCleanAction:(UIBarButtonItem*)sender {
    
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"确认清除所有消息？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (void)layoutMessageTableView {
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight) style:UITableViewStylePlain];
    [self setMessageTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    //[self setTableViewHeaderView:0];
    [self setTableViewFooterView:0];
}

-(void)setTableViewHeaderView:(NSInteger)height {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _messageTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_messageTableView setTableHeaderView:view];
}

-(void)setTableViewFooterView:(NSInteger)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _messageTableView.frame.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    [_messageTableView setTableFooterView:view];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_messageList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"discoverTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [cell.contentView addSubview:line];
    }
    
    MessageInfo *msgInfo = [_messageList objectAtIndex:indexPath.row];
    NSString *timeString = msgInfo.updateDate;
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:[timeString longLongValue]/1000];
    
    //获取日期
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:updateDate];

    NSDictionary *attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:28], NSForegroundColorAttributeName:[UIColor blackColor] };
    
    NSDictionary *attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor blackColor] };
    
    NSString *str1 = [NSString stringWithFormat:@"%2ld",(long)comps.day];
    NSString *str2 = [NSString stringWithFormat:@"%2ld月",(long)comps.month];;
    NSString *str = [NSString stringWithFormat:@"%@%@",str1,str2];
    NSRange range1 = [str rangeOfString:str1];
    NSRange range2 = [str rangeOfString:str2];
    
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str];
    [att1 addAttributes:attributes1 range:range1];
    [att1 addAttributes:attributes2 range:range2];
    
    cell.textLabel.attributedText = att1;
    

    NSString *subString = msgInfo.content;
    NSRange rang3 = [subString rangeOfString:msgInfo.reward];
    
    NSDictionary *sub_attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:0xa0a2a5] };
    
    NSDictionary *sub_attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor redColor] };
    
    NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc] initWithString:subString];
    [att2 addAttributes:sub_attributes1 range:NSMakeRange(0, [subString length])];
    [att2 addAttributes:sub_attributes2 range:rang3];
    
    cell.detailTextLabel.attributedText = att2;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"GetSystemMessage"] && result) {
        MessagesResult *messageRec = (MessagesResult*)result;
        [self setMessageList:messageRec.sysMessageList];
        
        if (messageRec.sysMessageList && [messageRec.sysMessageList count]) {
            UIBarButtonItem *rightButton = [self configBarButtonWithTitle:@"清除" target:self selector:@selector(navBarCleanAction:)];
            self.navigationItem.rightBarButtonItem = rightButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        [_messageTableView reloadData];
    }
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
