//
//  QuestionTableViewCell.m
//  Answer
//
//  Created by wuyj on 15/12/16.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionTableViewCell.h"
#import "QuestionInfoView.h"

@interface QuestionTableViewCell ()
@property (nonatomic, strong) QuestionInfoView *infoView;
@end

@implementation QuestionTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)setDelegate:(id<QuestionInfoViewDelegate>)delegate {
    self.infoView.delegate = delegate;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        QuestionInfoView *infoView = [[QuestionInfoView alloc] initWithFrame:CGRectZero];
        self.infoView = infoView;
        [self.contentView addSubview:infoView];
    }
    
    return self;
}


- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo {
    
    [self.infoView setQuestionInfo:questionInfo userInfo:userInfo];
    [self.infoView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.contentView setFrame:self.bounds];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}

- (CGFloat)cellHeight {
    return [self.infoView viewHeight];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.infoView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.contentView setFrame:self.bounds];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}

@end
