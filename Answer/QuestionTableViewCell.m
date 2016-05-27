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
        __weak QuestionTableViewCell *wSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            QuestionTableViewCell *sSelf = wSelf;
            
            QuestionInfoView *infoView = [[QuestionInfoView alloc] initWithFrame:CGRectMake(0, 0, [DeviceInfo screenWidth], 0)];
            sSelf.infoView = infoView;
            [sSelf addSubview:infoView];
        });
    }
    
    return self;
}


- (void)setQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave {
    
    __weak QuestionTableViewCell *wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        QuestionTableViewCell *sSelf = wSelf;
        
        [sSelf.infoView setFrame:CGRectMake(0, 0, [DeviceInfo screenWidth], self.frame.size.height)];
        [sSelf.infoView setQuestionInfo:questionInfo haveUserView:isHave];
        [sSelf setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, [DeviceInfo screenWidth], self.frame.size.height)];
    });
}



+ (CGFloat)cellHeightByQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave {
    QuestionInfoView *infoView = [QuestionInfoView sharedQuestionInfoView];
    return [infoView viewHeightByQuestionInfo:questionInfo haveUserView:isHave isFoldText:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.infoView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
}

@end
