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
#import "DeleteMessageResult.h"
#import "QuestionDetailVC.h"
#import "MessageTableViewCell.h"

@interface SystemMessageVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate,UIActionSheetDelegate>
@property(nonatomic,strong)UITableView          *messageTableView;
@property(nonatomic,strong)NSMutableArray       *messageList;
@property(nonatomic,strong)NSIndexPath          *delIndexPath;
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


- (void)deleteAllMessage {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    
    [param setObject:@"delAll" forKey:@"wtype"];
    [param setObject:@"0" forKey:@"uId"];//无效
    
    if (_messageType == MessageType_atMe) {
        [param setObject:@"1" forKey:@"fenlei"];
    } else if(_messageType == MessageType_system) {
        [param setObject:@"2" forKey:@"fenlei"];
    } else {
        [param setObject:@"0" forKey:@"fenlei"];
    }
    
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_DelSystemMessage
                                             forParam:param
                                             delegate:self
                                            resultObj:[[DeleteMessageResult alloc] init]
                                           customInfo:@"deleteAllMessage"];
}


- (void)deleteOneMessage:(MessageInfo*)message {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    
    [param setObject:@"part" forKey:@"wtype"];
    [param setObject:message.uId forKey:@"uId"];
    
    if (_messageType == MessageType_atMe) {
        [param setObject:@"1" forKey:@"fenlei"];
    } else if(_messageType == MessageType_system) {
        [param setObject:@"2" forKey:@"fenlei"];
    } else {
        [param setObject:@"0" forKey:@"fenlei"];
    }
    
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_DelSystemMessage
                                             forParam:param
                                             delegate:self
                                            resultObj:[[DeleteMessageResult alloc] init]
                                           customInfo:@"deleteOneMessage"];
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"GetSystemMessage"] && result) {
        MessagesResult *messageRec = (MessagesResult*)result;
        [self setMessageList:[NSMutableArray arrayWithArray:messageRec.sysMessageList]];
        
        if (messageRec.sysMessageList && [messageRec.sysMessageList count]) {
            UIBarButtonItem *rightButton = [self configBarButtonWithTitle:@"清除" target:self selector:@selector(navBarCleanAction:)];
            self.navigationItem.rightBarButtonItem = rightButton;
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        [_messageTableView reloadData];
    } else if([customInfo isEqualToString:@"deleteAllMessage"] && result) {
        // 删除所有消息
        [FadePromptView showPromptStatus:@"删除成功" duration:1.0 finishBlock:^{
            //
            [_messageTableView setHidden:YES];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
    } else if ([customInfo isEqualToString:@"deleteOneMessage"]) {
        
        // 删除单个消息
        if (_delIndexPath && _delIndexPath.row < [_messageList count]) {
            [_messageList removeObjectAtIndex:_delIndexPath.row];
            [FadePromptView showPromptStatus:@"删除成功" duration:1.0 finishBlock:^{
                //
                [_messageTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_delIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            }];
        }
    }
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
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
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //
        MessageInfo *info = [_messageList objectAtIndex:indexPath.row];
        self.delIndexPath = indexPath;
        [self deleteOneMessage:info];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_messageList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifier = @"discoverTableCell";
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        UIView *selBGView = [[UIView alloc] initWithFrame:cell.bounds];
        [selBGView setBackgroundColor:[UIColor colorWithHex:0xeeeeee]];
        cell.selectedBackgroundView = selBGView;

        LineView *line = [[LineView alloc] initWithFrame:CGRectZero];
        line.tag = 1000;
        [cell.contentView addSubview:line];
    }

    if (_messageType == MessageType_system) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    MessageInfo *msgInfo = [_messageList objectAtIndex:indexPath.row];
    NSString *timeString = msgInfo.updateDate;
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:[timeString longLongValue]/1000];

    //
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:updateDate];

    NSString *str2 = [NSString stringWithFormat:@"%02d日",(int)comps.day];
    NSString *str1 = [NSString stringWithFormat:@"%02d月",(int)comps.month];
    NSString *str = [NSString stringWithFormat:@"%@%@  ",str1,str2];
    
    NSString *content = msgInfo.content;
    if (content && [content length]) {
        str = [str stringByAppendingString:content];
    }

    cell.textLabel.text = str;
    
    CGSize size = [str sizeWithFontCompatible:cell.textLabel.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 60, CGFLOAT_MAX) lineBreakMode:cell.textLabel.lineBreakMode];
    LineView *line = (LineView*)[cell.contentView viewWithTag:1000];
    CGFloat height = size.height + 10;
    if (height - 50 < 0.0) {
        height = 50;
    }
    
    [line setFrame:CGRectMake(0, height - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];

    return cell;
}



//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    static NSString *cellIdentifier = @"discoverTableCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
//        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        
//        UIView *selBGView = [[UIView alloc] initWithFrame:cell.bounds];
//        [selBGView setBackgroundColor:[UIColor colorWithHex:0xeeeeee]];
//        cell.selectedBackgroundView = selBGView;
//        
//        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 50-kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
//        [cell.contentView addSubview:line];
//    }
//    
//    if (_messageType == MessageType_system) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    }
//    
//    MessageInfo *msgInfo = [_messageList objectAtIndex:indexPath.row];
//    NSString *timeString = msgInfo.updateDate;
//    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:[timeString longLongValue]/1000];
//    
//    //
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
//    NSDateComponents *comps = [calendar components:unitFlags fromDate:updateDate];
//
//    NSDictionary *attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:28], NSForegroundColorAttributeName:[UIColor redColor] };
//    
//    NSDictionary *attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor blackColor] };
//    
//    NSString *str1 = [NSString stringWithFormat:@"%02d日",(int)comps.day];
//    NSString *str2 = [NSString stringWithFormat:@"%02d月",(int)comps.month];
//    NSString *str = [NSString stringWithFormat:@"%@%@",str1,str2];
//    NSRange range1 = [str rangeOfString:str1];
//    NSRange range2 = [str rangeOfString:str2];
//    
//    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str];
//    [att1 addAttributes:attributes1 range:range1];
//    [att1 addAttributes:attributes2 range:range2];
//    
//    cell.textLabel.attributedText = att1;
//    
//
//    NSString *subString = msgInfo.content;
//    NSRange rang3 = [subString rangeOfString:msgInfo.reward];
//    
//    NSDictionary *sub_attributes1 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor colorWithHex:0xa0a2a5] };
//    
//    NSDictionary *sub_attributes2 = @{ NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor redColor] };
//    
//    NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc] initWithString:subString];
//    [att2 addAttributes:sub_attributes1 range:NSMakeRange(0, [subString length])];
//    [att2 addAttributes:sub_attributes2 range:rang3];
//    
//    cell.detailTextLabel.attributedText = att2;
//
//    return cell;
//}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageInfo *msgInfo = [_messageList objectAtIndex:indexPath.row];
    NSString *timeString = msgInfo.updateDate;
    NSDate *updateDate = [NSDate dateWithTimeIntervalSince1970:[timeString longLongValue]/1000];
    
    //
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:updateDate];
    
    NSString *str1 = [NSString stringWithFormat:@"%02d月",(int)comps.month];
    NSString *str2 = [NSString stringWithFormat:@"%02d日",(int)comps.day];
    
    NSString *str = [NSString stringWithFormat:@"%@%@  ",str1,str2];
    
    NSString *content = msgInfo.content;
    if (content && [content length]) {
        str = [str stringByAppendingString:content];
    }
    
    CGSize size = [str sizeWithFontCompatible:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(tableView.frame.size.width - 60, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height + 10;
    if (height - 50 < 0.0) {
        height = 50;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_messageType == MessageType_system) {
        
    } else {
        MessageInfo *msgInfo = [_messageList objectAtIndex:indexPath.row];
        QuestionDetailVC *vc = [[QuestionDetailVC alloc] init];
        vc.tuWenId = msgInfo.tuwenId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        
        [self deleteAllMessage];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
