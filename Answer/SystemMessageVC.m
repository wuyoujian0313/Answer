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

@interface SystemMessageVC ()<UITableViewDataSource,UITableViewDelegate,NetworkTaskDelegate>
@property(nonatomic,strong)UITableView          *messageTableView;
@property(nonatomic,strong)NSArray              *messageList;
@end

@implementation SystemMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"系统消息"];
    [self layoutMessageTableView];
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
    return 4;
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
    UILabel *titleLabel = cell.textLabel;
    UILabel *subTitleLabel = cell.detailTextLabel;
    
    NSDictionary *attributes1 = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:28],
                                 NSForegroundColorAttributeName:[UIColor blackColor]
                                 };
    NSDictionary *attributes2 = @{
                                  NSFontAttributeName:[UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName:[UIColor blackColor]
                                  };
    NSString *str1 = @"22";
    NSString *str2 = @"8月";
    NSString *str = [NSString stringWithFormat:@"%@%@",str1,str2];
    NSRange range1 = [str rangeOfString:str1];
    NSRange range2 = [str rangeOfString:str2];
    
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:str];
    
    [att1 addAttributes:attributes1 range:range1];
    [att1 addAttributes:attributes2 range:range2];
    
    titleLabel.attributedText = att1;
    
    //////////////
    NSString *subString = @"你在回复****的问题，获得8元";
    NSRange rang3 = [subString rangeOfString:@"8"];
    
    NSDictionary *sub_attributes1 = @{
                                  NSFontAttributeName:[UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName:[UIColor colorWithHex:0xa0a2a5]
                                  };
    
    NSDictionary *sub_attributes2 = @{
                                  NSFontAttributeName:[UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName:[UIColor redColor]
                                  };
    
    NSMutableAttributedString *att2 = [[NSMutableAttributedString alloc] initWithString:subString];
    [att2 addAttributes:sub_attributes1 range:NSMakeRange(0, [subString length])];
    [att2 addAttributes:sub_attributes2 range:rang3];
    
    subTitleLabel.attributedText = att2;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    
}

-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
