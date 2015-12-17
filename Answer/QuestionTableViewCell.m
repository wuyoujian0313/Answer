//
//  QuestionTableViewCell.m
//  Answer
//
//  Created by wuyj on 15/12/16.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "TTTTimeIntervalFormatter.h"
#import "AudioPlayControl.h"

@interface QuestionTableViewCell ()

@property (nonatomic, strong) UIView                *userInfoView;
@property (nonatomic, strong) UIView                *wtContentView;
@property (nonatomic, strong) UIView                *funcView;
@property (nonatomic, strong) QuestionInfo          *questionInfo;
@property (nonatomic, strong) UserInfo              *userInfo;
@property (nonatomic, assign) BOOL                  haveUserInfo;

@property (nonatomic, assign) CGFloat               userInfoViewHeight;
@property (nonatomic, assign) CGFloat               wtContentViewHeight;
@property (nonatomic, assign) CGFloat               funcViewHeight;

@end

@implementation QuestionTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        self.haveUserInfo = NO;
        [self layoutUserView:self.contentView];
        [self layoutWtContentView:self.contentView];
        [self layoutFuncView:self.contentView];
        
    }
    
    return self;
}


// tag == 100
- (void)layoutUserView:(UIView *)viewParent {
    if (viewParent != nil) {
        
        if (self.userInfoView == nil) {
            self.userInfoView = [[UIView alloc] initWithFrame:CGRectZero];
            [_userInfoView setBackgroundColor:[UIColor whiteColor]];
            [viewParent addSubview:_userInfoView];
        }
        
        if (_haveUserInfo) {
            [_userInfoView setFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        } else {
            [_userInfoView setFrame:CGRectZero];
        }
        
        
        CGFloat left = 10;
        CGFloat top = 10;
        
        UIImageView *photoImage = (UIImageView *)[_userInfoView viewWithTag:100];
        if (photoImage == nil) {
            photoImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            [photoImage setTag:100];
            [photoImage.layer setCornerRadius:40/2.0];
            [photoImage setClipsToBounds:YES];
            [_userInfoView addSubview:photoImage];
        }
        
        [photoImage setFrame:CGRectMake(left, top, 40, 40)];
        
        UILabel  *nameLabel = (UILabel *)[_userInfoView viewWithTag:101];
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTag:101];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setTextColor:[UIColor colorWithHex:0x666666]];
            [nameLabel setFont:[UIFont systemFontOfSize:14]];
            [_userInfoView addSubview:nameLabel];
        }
        
        
        
    }
}


// tag == 200
- (void)layoutWtContentView:(UIView *)viewParent {
    if (viewParent != nil) {
        
        if (self.wtContentView == nil) {
            self.wtContentView = [[UIView alloc] initWithFrame:CGRectZero];
            [_wtContentView setBackgroundColor:[UIColor whiteColor]];
            [viewParent addSubview:_wtContentView];
        }
        
        // 语音播放按钮 200
        AudioPlayControl *audioControl = (AudioPlayControl *)[_wtContentView viewWithTag:200];
        if (audioControl == nil) {
            audioControl = [[AudioPlayControl alloc] initWithFrame:CGRectZero];
            [audioControl setTag:200];
            [audioControl addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
            [_wtContentView addSubview:audioControl];
        }

        // 图片 & 视频图片
        UIImageView *contentImage = (UIImageView *)[_wtContentView viewWithTag:201];
        if (contentImage == nil) {
            contentImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            [contentImage setUserInteractionEnabled:YES];
            [contentImage setTag:201];
            [_wtContentView addSubview:contentImage];
        }
        
        // 视频播放按钮
        UIButton *playBtn = (UIButton*)[_wtContentView viewWithTag:202];
        if (playBtn == nil) {
            playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [playBtn setTag:202];
            [playBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            [_wtContentView addSubview:playBtn];
        }
        
        //
        
    }
}

- (void)playVideo:(UIButton *)sender {
    
}

- (void)playAudio:(AudioPlayControl*)sender {
    
}


// tag == 300
- (void)layoutFuncView:(UIView *)viewParent {
    
    if (viewParent != nil) {
        
        if (self.funcView == nil) {
            self.funcView = [[UIView alloc] initWithFrame:CGRectZero];
            [_funcView setBackgroundColor:[UIColor whiteColor]];
            [viewParent addSubview:_funcView];
        }
        
    }
}

- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo {
    
    if (userInfo) {
        _haveUserInfo = YES;
    } else {
        _haveUserInfo = NO;
    }
    
    _userInfoViewHeight = 0;
    _wtContentViewHeight = 0;
    _funcViewHeight = 0;
    
    self.questionInfo = questionInfo;
    self.userInfo = userInfo;
    
    [self layoutUserView:self.contentView];
    [self layoutWtContentView:self.contentView];
    [self layoutFuncView:self.contentView];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, [self cellHeight]);
}

- (CGFloat)cellHeight {
    return _userInfoViewHeight + _wtContentViewHeight + _funcViewHeight;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutUserView:self.contentView];
    [self layoutWtContentView:self.contentView];
    [self layoutFuncView:self.contentView];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, [self cellHeight]);
}

@end
