//
//  QuestionsView.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionsView.h"
#import "QuestionTableViewCell.h"


@interface QuestionsView ()<UITableViewDataSource,UITableViewDelegate,NSCacheDelegate,MJRefreshBaseViewDelegate>

@property (nonatomic, strong) UITableView           *questionTableView;
@property (nonatomic, strong) QuestionsResult       *questions;
@property (nonatomic, assign) BOOL                  haveUserView;
@property (nonatomic, strong) NSCache               *cellCache;

@property (nonatomic, strong) MJRefreshHeaderView   *refreshHeader;
@property (nonatomic, strong) MJRefreshFooterView   *refreshFootder;

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
        
        UITableView * tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self setQuestionTableView:tableView];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setBackgroundColor:[UIColor clearColor]];
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
    [_questionTableView reloadData];
}


- (void)setQuestionsResult:(QuestionsResult *)result {
    self.questions = result;
    [self endRefresh];
    [_questionTableView reloadData];
}

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView  {
    if (_refreshDelegate && [_refreshDelegate respondsToSelector:@selector(refreshViewBeginRefreshing:)]) {
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
    return [[_questions twList] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_delegate && [_delegate respondsToSelector:@selector(questionInfoViewAction:questionInfo:userInfo:)]) {
        
        QuestionInfo *questionInfo = [[_questions twList] objectAtIndex:indexPath.row];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",questionInfo.userId];
        
        // 理论上只有一个
        NSArray *users = [[_questions userList] filteredArrayUsingPredicate:predicate];
        if (users && [users count]) {
            [_delegate questionInfoViewAction:QuestionInfoViewAction_ScanDetail questionInfo:questionInfo userInfo:[users objectAtIndex:0]];
        } else {
            [_delegate questionInfoViewAction:QuestionInfoViewAction_ScanDetail questionInfo:questionInfo userInfo:nil];
        } 
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < [[_questions twList] count]) {
        return [self tableView:tableView preparedCellForIndexPath:indexPath];
    }
    
    //
    static NSString *cellIdentifier = @"QuestionTableCellEx";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
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
        }
    }
    
    // 设置数据
    cell.delegate = _delegate;
    [_cellCache setObject:cell forKey:key];
    QuestionInfo *questionInfo = [[_questions twList] objectAtIndex:indexPath.row];
    
    if (_haveUserView) {
        //
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",questionInfo.userId];
        
        // 理论上只有一个
        NSArray *users = [[_questions userList] filteredArrayUsingPredicate:predicate];
        if (users && [users count]) {
            [cell setQuestionInfo:questionInfo userInfo:[users objectAtIndex:0]];
        } else {
            [cell setQuestionInfo:questionInfo userInfo:nil];
        }
    } else {
        [cell setQuestionInfo:questionInfo userInfo:nil];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[_questions twList] count]) {
        QuestionTableViewCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        return [cell cellHeight];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [[_questions twList] count]) {
        QuestionTableViewCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        return [cell cellHeight];
    }
    
    return 0;
}




@end
