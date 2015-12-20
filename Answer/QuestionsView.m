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
#warning wuyoujian
    return 2;
    //return [[_questions twList] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (1||indexPath.row < [[_questions twList] count]) {
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
        QuestionInfo *questionInfo = [[_questions twList] objectAtIndex:indexPath.row];
        
        
        QuestionInfo *q = [[QuestionInfo alloc] init];
        q.mediaType = [NSNumber numberWithInt:0];
        q.mediaURL = @"http://d.hiphotos.baidu.com/image/h%3D220/sign=8ac0a7ed217f9e2f6f351a0a2f30e962/d8f9d72a6059252dff61080f329b033b5bb5b942.jpg";
        q.thumbnail = @"http://d.hiphotos.baidu.com/image/h%3D220/sign=8ac0a7ed217f9e2f6f351a0a2f30e962/d8f9d72a6059252dff61080f329b033b5bb5b942.jpg";
        q.content = @"北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京";
        q.type = @"军事 武器";
        q.reward = @"5元";
        q.address = @"北京 奎科大厦";
        q.updateDate  = @"12:00";
        q.duration = [NSNumber numberWithInt:20];
        
        UserInfo *info = [[UserInfo alloc] init];
        info.nickName = @"老武";
        info.headImage = @"http://img.idol001.com/middle/2015/06/03/9e9b4afaa9228f72890749fe77dcf48b1433311330.jpg";
        info.level = [NSNumber numberWithInt:5];
        
        questionInfo = q;
        [cell setQuestionInfo:questionInfo userInfo:info];
        return cell;
        
        if (_haveUserView) {
            //
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",questionInfo.uId];
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
    
    // 设置数据

    [_cellCache setObject:cell forKey:key];
    QuestionInfo *questionInfo = [[_questions twList] objectAtIndex:indexPath.row];
    
    QuestionInfo *q = [[QuestionInfo alloc] init];
    q.mediaType = [NSNumber numberWithInt:0];
    q.mediaURL = @"http://d.hiphotos.baidu.com/image/h%3D220/sign=8ac0a7ed217f9e2f6f351a0a2f30e962/d8f9d72a6059252dff61080f329b033b5bb5b942.jpg";
    q.thumbnail = @"http://d.hiphotos.baidu.com/image/h%3D220/sign=8ac0a7ed217f9e2f6f351a0a2f30e962/d8f9d72a6059252dff61080f329b033b5bb5b942.jpg";
    q.content = @"北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京北京";
    q.type = @"军事 武器";
    q.reward = @"5元";
    q.address = @"北京 奎科大厦";
    q.updateDate  = @"12:00";
    q.duration = [NSNumber numberWithInt:20];
    
    UserInfo *info = [[UserInfo alloc] init];
    info.nickName = @"老武";
    info.headImage = @"http://img.idol001.com/middle/2015/06/03/9e9b4afaa9228f72890749fe77dcf48b1433311330.jpg";
    info.level = [NSNumber numberWithInt:5];
    
    questionInfo = q;
    [cell setQuestionInfo:questionInfo userInfo:info];
    
    return cell;
    
    
    if (_haveUserView) {
        //
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uId==%@",questionInfo.uId];
        
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
    
    if (1||indexPath.row < [[_questions twList] count]) {
        QuestionTableViewCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        return [cell cellHeight];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (1||indexPath.row < [[_questions twList] count]) {
        QuestionTableViewCell *cell = [self tableView:tableView preparedCellForIndexPath:indexPath];
        return [cell cellHeight];
    }
    
    return 0;
}




@end
