//
//  QuestionsView.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionsView.h"
#import "QuestionTableViewCell.h"

@interface QuestionsView ()<UITableViewDataSource,UITableViewDelegate,NSCacheDelegate>

@property (nonatomic, strong) UITableView           *questionTableView;
@property (nonatomic, strong) QuestionsResult       *questions;
@property (nonatomic, assign) BOOL                  haveUserView;
@property(nonatomic,strong) NSCache                 *cellCache;

@end


@implementation QuestionsView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame haveUserView:YES delegate:nil];
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<QuestionTableViewCellDelegate>)delegate {
    return [self initWithFrame:frame haveUserView:YES delegate:delegate];
}

- (instancetype)initWithFrame:(CGRect)frame haveUserView:(BOOL)isHave delegate:(id<QuestionTableViewCellDelegate>)delegate {
    
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
    }
    
    return self;
}


- (void)setQuestionsResult:(QuestionsResult *)result {
    self.questions = result;
    
    [_questionTableView reloadData];
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
        
        // 设置数据
        [_cellCache setObject:cell forKey:key];
        
        return cell;
    }
    
    // 设置数据

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
