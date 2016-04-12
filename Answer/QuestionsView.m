//
//  QuestionsView.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionsView.h"
#import "QuestionTableViewCell.h"
#import "User.h"


@interface QuestionsView ()<UITableViewDataSource,UITableViewDelegate,NSCacheDelegate,MJRefreshBaseViewDelegate>

@property (nonatomic, strong) UITableView           *questionTableView;
@property (nonatomic, assign) BOOL                  haveUserView;
@property (nonatomic, strong) NSCache               *cellCache;

@property (nonatomic, strong) MJRefreshHeaderView   *refreshHeader;
@property (nonatomic, strong) MJRefreshFooterView   *refreshFootder;

@property (nonatomic, strong) NSMutableArray        *questionList;
@property (nonatomic, strong) NSMutableArray        *userList;

@end


@implementation QuestionsView

-(void)dealloc {
    [_refreshHeader free];
    [_refreshFootder free];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame haveUserView:YES delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<QuestionInfoViewDelegate>)delegate {
    return [self initWithFrame:frame haveUserView:YES delegate:delegate];
}

- (instancetype)initWithFrame:(CGRect)frame haveUserView:(BOOL)isHave delegate:(id<QuestionInfoViewDelegate>)delegate {
    
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.haveUserView = isHave;
        self.delegate = delegate;
        self.clipsToBounds = YES;
        self.questionList = [[NSMutableArray alloc] init];
        self.userList = [[NSMutableArray alloc] init];
        
        UITableView * tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self setQuestionTableView:tableView];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setBackgroundColor:[UIColor colorWithHex:0xebeef0]];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:tableView];
        
        [self addRefreshHeadder];
        [self addRefreshFootder];
    }
    
    return self;
}

-(void)addRefreshHeadder {
    self.refreshHeader = [MJRefreshHeaderView header];
    _refreshHeader.scrollView = _questionTableView;
    _refreshHeader.delegate = self;
}

-(void)addRefreshFootder {
    self.refreshFootder = [MJRefreshFooterView footer];
    _refreshFootder.scrollView = _questionTableView;
    _refreshFootder.delegate = self;
}

- (void)beginRefreshing {
    [_refreshHeader beginRefreshing];
}

-(void)endRefresh {
    if ([_refreshHeader isRefreshing]) {
        [_refreshHeader endRefreshing];
    }
    
    if ([_refreshFootder isRefreshing]) {
        [_refreshFootder endRefreshing];
    }
}

- (void)reloadQuestionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_questionTableView reloadData];
    });
}

- (void)clearTableViewData {
    [_questionList removeAllObjects];
    [_userList removeAllObjects];
    [_cellCache removeAllObjects];
    _cellCache = nil;
}

- (void)addQuestionsResult:(QuestionsResult *)result {
    
    if (result.twList && [result.twList count]) {
        if ([result.twList count] <= 30) {
            [_refreshFootder setHidden:YES];
        } else {
            [_refreshFootder setHidden:NO];
        }
        [_questionList addObjectsFromArray:result.twList];
    }
    
    if (result.userList && [result.userList count]) {
        
        for (UserInfo * user in result.userList) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",user.uId];
            
            // 数组里不存在用户
            NSArray *users = [_userList filteredArrayUsingPredicate:predicate];
            if (users == nil || [users count] == 0) {
                [_userList addObject:user];
            }
        }
    }

    [self endRefresh];
    [_questionTableView reloadData];
}

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView  {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshViewBeginRefreshing:)]) {
        
        if ([refreshView viewType] == MJRefreshViewTypeHeader) {
            [self clearTableViewData];
        }
        [_refreshDelegate refreshViewBeginRefreshing:refreshView];
    }
}

- (void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshViewEndRefreshing:)]) {
        [_refreshDelegate refreshViewEndRefreshing:refreshView];
    }
}

#pragma mark - NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {

}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_questionList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_delegate && [_delegate respondsToSelector:@selector(questionInfoViewAction:questionInfo:userInfo:)]) {
        
        QuestionInfo *questionInfo = [_questionList objectAtIndex:indexPath.row];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",questionInfo.userId];
        
        // 理论上只有一个
        NSArray *users = [_userList filteredArrayUsingPredicate:predicate];
        if (users && [users count]) {
            [_delegate questionInfoViewAction:QuestionInfoViewAction_ScanDetail questionInfo:questionInfo userInfo:[users objectAtIndex:0]];
        } else {
            [_delegate questionInfoViewAction:QuestionInfoViewAction_ScanDetail questionInfo:questionInfo userInfo:nil];
        } 
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [_questionList count]) {
        return [self tableView:tableView preparedCellForIndexPath:indexPath];
    }
    
    //
    return nil;
}


- (QuestionTableViewCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath {
    
    if (self.cellCache == nil) {
        self.cellCache = [[NSCache alloc] init];
        _cellCache.delegate = self;
        _cellCache.evictsObjectsWithDiscardedContent = YES;
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section, (long)indexPath.row];
    QuestionTableViewCell *cell = [_cellCache objectForKey:key];
    if (cell == nil) {
        static NSString *cellIdentifier = @"QuestionTableCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [_cellCache setObject:cell forKey:key];
        }
        
        
    }
    
    // 设置数据
    cell.delegate = _delegate;
    QuestionInfo *questionInfo = [_questionList objectAtIndex:indexPath.row];
    
    if (_haveUserView) {
        
        if ([questionInfo.userId isEqualToString:[User sharedUser].user.uId]) {
            // 是自己的问题
            [cell setQuestionInfo:questionInfo userInfo:[User sharedUser].user];
        } else {
            //
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",questionInfo.userId];
            
            // 理论上只有一个
            NSArray *users = [_userList filteredArrayUsingPredicate:predicate];
            if (users && [users count]) {
                [cell setQuestionInfo:questionInfo userInfo:[users objectAtIndex:0]];
            } else {
                [cell setQuestionInfo:questionInfo userInfo:nil];
            }
        }
        
        
    } else {
        [cell setQuestionInfo:questionInfo userInfo:nil];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_questionList count]) {
        QuestionTableViewCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        return [cell cellHeight];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_questionList count]) {
        QuestionTableViewCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        return [cell cellHeight];
    }
    
    return 0;
}




@end
