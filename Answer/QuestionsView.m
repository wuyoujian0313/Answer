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

#define saveQuestionListToLocalKey      @"saveQuestionListToLocalKey"

@interface QuestionsView ()<UITableViewDataSource,UITableViewDelegate,NSCacheDelegate,MJRefreshBaseViewDelegate>

@property (nonatomic, strong) UITableView           *questionTableView;
@property (nonatomic, assign) BOOL                  haveUserView;
@property (nonatomic, strong) NSCache               *cellHeightCache;

@property (nonatomic, strong) MJRefreshHeaderView   *refreshHeader;
@property (nonatomic, strong) MJRefreshFooterView   *refreshFootder;
@property (nonatomic, strong) NSMutableArray        *questionList;

@end


@implementation QuestionsView

-(void)dealloc {
    [_refreshHeader free];
    [_refreshFootder free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

        UITableView * tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [self setQuestionTableView:tableView];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setBackgroundColor:[UIColor colorWithHex:0xebeef0]];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:tableView];
        
        [self addRefreshHeadder];
        [self addRefreshFootder];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadQuestionDataFromLocal) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveQuestionDataToLocal) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteQuestionDataFromLocal) name:UIApplicationWillTerminateNotification object:nil];
        
        if (self.cellHeightCache == nil) {
            self.cellHeightCache = [[NSCache alloc] init];
            _cellHeightCache.delegate = self;
        }
    }
    
    return self;
}

- (void)deleteQuestionDataFromLocal {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:saveQuestionListToLocalKey];
    [userDefaults synchronize];
}

- (void)saveQuestionDataToLocal {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (_questionList) {
        NSData *listData = [NSKeyedArchiver archivedDataWithRootObject:_questionList];
        [userDefaults setObject:listData forKey:saveQuestionListToLocalKey];
    }
    
    [userDefaults synchronize];
    
    User *user = [User sharedUser];
    [user saveToUserDefault];
    
    //
    [self clearTableViewData];
}

- (void)reloadQuestionDataFromLocal {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSData *listData = [userDefaults objectForKey:saveQuestionListToLocalKey];
        if (listData && [listData isKindOfClass:[NSData class]]) {
            NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:listData];
            if (arr) {
                self.questionList = [[NSMutableArray alloc] initWithArray:arr];
            }
        }
        
        User *user = [User sharedUser];
        [user loadFromUserDefault];
        
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            //
        });
    });
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

- (void)endRefresh {
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

- (void)clearCacheData {
    [_cellHeightCache removeAllObjects];
    _cellHeightCache = nil;
}

- (void)clearTableViewData {
    [_questionList removeAllObjects];
    [self clearCacheData];
}

- (void)addQuestionsResult:(QuestionsResult *)result {
    
    if (result.twList && [result.twList count]) {
        if ([result.twList count] < 30) {
            [_refreshFootder setHidden:YES];
        } else {
            [_refreshFootder setHidden:NO];
        }
        [_questionList addObjectsFromArray:result.twList];
    }

    [_questionTableView reloadData];
    [self endRefresh];
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
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_questionList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_delegate && [_delegate respondsToSelector:@selector(questionInfoViewAction:questionInfo:)]) {
        
        QuestionInfo *questionInfo = [_questionList objectAtIndex:indexPath.row];
        [_delegate questionInfoViewAction:QuestionInfoViewAction_ScanDetail questionInfo:questionInfo];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self tableView:tableView preparedCellForIndexPath:indexPath];;
}


- (QuestionTableViewCell *)tableView:(UITableView *)tableView preparedCellForIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"QuestionTableViewCell";
    QuestionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 设置数据
    cell.delegate = _delegate;
    if ([_questionList count] > indexPath.row) {
        QuestionInfo *questionInfo = [_questionList objectAtIndex:indexPath.row];
        [cell setQuestionInfo:questionInfo haveUserView:_haveUserView];
    }
    
    return cell;
}

- (CGFloat)cellHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = [NSString stringWithFormat:@"%ld-%ld",(long)indexPath.section,(long)indexPath.row];
    NSNumber *heightNum = [_cellHeightCache objectForKey:key];
    if (heightNum) {
        return [heightNum floatValue];
    }
    
    CGFloat height = 0;
    if ([_questionList count] > indexPath.row) {
        QuestionInfo *questionInfo = [_questionList objectAtIndex:indexPath.row];
        height = [QuestionTableViewCell cellHeightByQuestionInfo:questionInfo haveUserView:_haveUserView];
    }
    
    if (self.cellHeightCache == nil) {
        self.cellHeightCache = [[NSCache alloc] init];
        _cellHeightCache.delegate = self;
    }
    
    [_cellHeightCache setObject:[NSNumber numberWithFloat:height] forKey:key];

    
    return height;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_questionList count]) {
        return [self cellHeightForIndexPath:indexPath];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [_questionList count]) {
        return [self cellHeightForIndexPath:indexPath];
    }
    
    return 0;
}




@end
