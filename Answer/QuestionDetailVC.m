//
//  QuestionDetailVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionDetailVC.h"
#import "ProtocolDefine.h"
#import "QuestionInfoView.h"
#import "AnswerTableViewCell.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "HPGrowingTextView.h"
#import "User.h"
#import "QuestionDetailResult.h"
#import "QuestionInfo.h"
#import "UserInfo.h"
#import "NetworkTask.h"
#import "AnswerResult.h"


@interface QuestionDetailVC ()<QuestionInfoViewDelegate,UITableViewDataSource,UITableViewDelegate,HPGrowingTextViewDelegate,NetworkTaskDelegate>

@property(nonatomic,strong)UITableView                  *detailTableView;
@property(nonatomic,copy)NSString                       *guanzhuFriendId;

@property(nonatomic,strong)QuestionInfoView             *questionInfoView;
@property(nonatomic,strong)UIView                       *containerView;
@property(nonatomic,strong)HPGrowingTextView            *commentTextView;
@property(nonatomic,copy)NSString                       *commentString;
@property(nonatomic,strong)UIButton                     *sendBtn;
@property(nonatomic,strong)NSMutableArray               *answerList;
@property(nonatomic,strong)NSArray                      *userList;

@property (nonatomic, strong) QuestionInfo              *questionInfo;
@property (nonatomic, strong) UserInfo                  *userInfo;

@end

@implementation QuestionDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"问题详情"];
    [self layoutDetailView];
    [self layoutCommentView];
    [self requestQuestionDetail];
}

- (void)requestQuestionDetail {
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [User sharedUser].user.uId,@"userId",
                          _tuWenId,@"uId",nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_GetTuWenDetail
                                             forParam:param
                                             delegate:self
                                            resultObj:[[QuestionDetailResult alloc] init]
                                           customInfo:@"getTuWenDetail"];
}

- (void)layoutCommentView {
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    
    
    LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, 0,_containerView.frame.size.width, kLineHeight1px)];
    [_containerView addSubview:line];
    
    self.commentTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10,(44 - 31)/2.0, _containerView.frame.size.width - 60, 31)];
    _commentTextView.isScrollable = NO;
    _commentTextView.contentInset = UIEdgeInsetsMake(17, 10, 17, 10);
    _commentTextView.minNumberOfLines = 1;
    _commentTextView.maxNumberOfLines = 6;
    _commentTextView.returnKeyType = UIReturnKeyNext;
    _commentTextView.font = [UIFont systemFontOfSize:14];
    _commentTextView.delegate = self;
    [_commentTextView.layer setCornerRadius:5.0];
    [_commentTextView.layer setBorderWidth:kLineHeight1px];
    [_commentTextView.layer setBorderColor:[UIColor colorWithHex:0xcccccc].CGColor];
    
    _commentTextView.clipsToBounds = YES;
    _commentTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _commentTextView.backgroundColor = [UIColor whiteColor];
    _commentTextView.placeholder = @"回答问题(1-140个字)";
    _commentTextView.text = @"";
    [_containerView addSubview:_commentTextView];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendBtn setFrame:CGRectMake(_containerView.frame.size.width - 50,0, 50, 44)];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setEnabled:NO];
    [_sendBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_sendBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor colorWithHex:0xff0000] forState:UIControlStateHighlighted];
    [_sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_sendBtn addTarget:self action:@selector(sendAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [_containerView addSubview:_sendBtn];
    [self.view addSubview:_containerView];
}

- (void)sendAnswer:(UIButton*)sender {
    [_commentTextView resignFirstResponder];
    
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          [User sharedUser].user.uId,@"userId",
                          _tuWenId,@"uId",_commentString,@"content",nil];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_Answer
                                             forParam:param
                                             delegate:self
                                            resultObj:[[AnswerResult alloc] init]
                                           customInfo:@"Answer"];
}

- (void)layoutDetailView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height - navigationBarHeight - 44) style:UITableViewStylePlain];
    [self setDetailTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
}

- (void)setTableViewHeaderView {
    
    QuestionInfoView *infoView = [[QuestionInfoView alloc] initWithFrame:CGRectMake(0, 0, _detailTableView.frame.size.width, 0)];
    infoView.delegate = self;
    self.questionInfoView = infoView;
    
    [_questionInfoView setQuestionInfo:_questionInfo userInfo:_userInfo isFoldText:NO];
    [_questionInfoView setFrame:CGRectMake(0, 0, _detailTableView.frame.size.width, [_questionInfoView viewHeight])];
    
    [_detailTableView setTableHeaderView:_questionInfoView];
}

- (void)commitGuanzhu:(NSString*)friendId {
    
    //
    self.guanzhuFriendId = friendId;
    NSDictionary* param =[[NSDictionary alloc] initWithObjectsAndKeys:
                          friendId,@"friendId",
                          [User sharedUser].user.uId,@"userId",nil];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startPOSTTaskApi:API_Guanzhu
                                             forParam:param
                                             delegate:self
                                            resultObj:[[NetResultBase alloc] init]
                                           customInfo:@"Guanzhu"];
}

#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    
    if ([customInfo isEqualToString:@"getTuWenDetail"]) {
        QuestionDetailResult * detail = (QuestionDetailResult*)result;
        self.userInfo = detail.user;
        self.questionInfo = detail.tuwen;
        self.answerList = [[NSMutableArray alloc] initWithArray:detail.answers];
        self.userList = detail.userList;
        
        [self setTableViewHeaderView];
        [_detailTableView reloadData];
    } else if ([customInfo isEqualToString:@"Answer"]) {
        //AnswerResult * anResult = (AnswerResult*)result;
        [self requestQuestionDetail];
        _commentTextView.text = nil;
        _commentString = nil;
        
        [FadePromptView showPromptStatus:@"发表成功！" duration:1.0 finishBlock:^{
            //
        }];
    } else if ([customInfo isEqualToString:@"Guanzhu"]) {
        [[User sharedUser] addFriend:_guanzhuFriendId];
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGuanzhu object:nil];
        [FadePromptView showPromptStatus:@"关注成功" duration:1.0 finishBlock:^{
            
        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}


#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    
    NSString *temp = [NSString stringWithFormat:@"%@",growingTextView.text];
    if ([temp length] > 140) {
        growingTextView.text = _commentString;
        return;
    }
    
    self.commentString = temp;
    if ([growingTextView.text length] > 0) {
        _sendBtn.enabled = YES;
    } else {
        _sendBtn.enabled = NO;
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = _containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _containerView.frame = r;
    
    CGRect rSend = _sendBtn.frame;
    rSend.origin.y = (_containerView.frame.size.height - rSend.size.height)/2.0;
    _sendBtn.frame = rSend;
}

#pragma mark - keyboard Notification
-(void)keyboardWillShow:(NSNotification *)note{
    
    [super keyboardWillShow:note];
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _containerView.frame = containerFrame;
    
    [UIView commitAnimations];
}


-(void)keyboardWillHide:(NSNotification *)note{
    [super keyboardWillHide:note];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    _containerView.frame = containerFrame;
    
    [UIView commitAnimations];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_answerList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"answerTableCell";
    AnswerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AnswerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        LineView *line = [[LineView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height -kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
        [line setTag:100];
        line.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        [cell.contentView addSubview:line];
    }
    
    AnswerInfo *answerInfo = [_answerList objectAtIndex:indexPath.row];
    NSString *userId = answerInfo.userId;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",userId];
    // 理论上只有一个
    
    UserInfo *answer = nil;
    NSArray *users = [_userList filteredArrayUsingPredicate:predicate];
    if (users && [users count]) {
        answer = [users objectAtIndex:0];
        
        //从缓存取
        //取图片缓存
        SDImageCache * imageCache = [SDImageCache sharedImageCache];
        NSString *imageUrl  = answer.headImage;
        UIImage *default_image = [imageCache imageFromDiskCacheForKey:imageUrl];
        
        if (default_image == nil) {
            default_image = [UIImage imageNamed:@"defaultHeadImage"];
            
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:default_image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    cell.imageView.image = image;
                    [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
                }
            }];
        } else {
            cell.imageView.image = default_image;
        }
        
        NSString *content = answerInfo.content;
        cell.textLabel.text = content;
        
        CGSize size = [content sizeWithFontCompatible:cell.textLabel.font constrainedToSize:CGSizeMake(tableView.frame.size.width - 60, CGFLOAT_MAX) lineBreakMode:cell.textLabel.lineBreakMode];
        LineView *line = (LineView*)[cell.contentView viewWithTag:100];
        CGFloat height = size.height + 20;
        if (height - 50 < 0.0) {
            height = 50;
        }
        
        [line setFrame:CGRectMake(0, height - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"headerIdentifier";
    
    UIView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (headerView == nil) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 12)];
        [headerView setBackgroundColor:[UIColor colorWithHex:0xebeef0]];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AnswerInfo *answerInfo = [_answerList objectAtIndex:indexPath.row];
    NSString *content = answerInfo.content;
    CGSize size = [content sizeWithFontCompatible:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(tableView.frame.size.width - 60, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = size.height + 20;
    if (height - 50 < 0.0) {
        height = 50;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - QuestionInfoViewCellDelegate
- (void)questionInfoViewAction:(QuestionInfoViewAction)action questionInfo:(QuestionInfo*)question userInfo:(UserInfo*)userInfo {
    
    switch (action) {
            
        case QuestionInfoViewAction_Attention:{
            [self commitGuanzhu:question.userId];
            break;
        }
        case QuestionInfoViewAction_PlayAudio:
            self.audioURL = [NSURL URLWithString:question.mediaURL];
            [self playReordFile];
            
            break;
        case QuestionInfoViewAction_PlayVideo:
            self.videoURL = [NSURL URLWithString:question.mediaURL];
            [self playVideo];
            
            break;
        case QuestionInfoViewAction_Answer:
        case QuestionInfoViewAction_ScanDetail: {
            break;
        }
        case QuestionInfoViewAction_Sharing:
            break;
        case QuestionInfoViewAction_RedPackage:
            break;
        case QuestionInfoViewAction_Location:
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
