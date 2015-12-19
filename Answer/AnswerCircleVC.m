//
//  AnswerCircleVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "AnswerCircleVC.h"
#import "QuestionsView.h"
#import "QuestionTableViewCell.h"

@interface AnswerCircleVC ()<QuestionTableViewCellDelegate>
@property (nonatomic, strong) QuestionsView *questionView;

@end

@implementation AnswerCircleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self layoutQuestionView];
}

- (void)layoutQuestionView {
    self.questionView = [[QuestionsView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, screenWidth, screenHeight - navigationBarHeight - 49) delegate:self];
    
    [self.view addSubview:_questionView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - QuestionTableViewCellDelegate
- (void)questionTableViewCellAction:(QuestionTableViewCellAction)action questionInfo:(QuestionInfo*)question {
    
}


@end
