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
#import "LineView.h"
#import "XHImageViewer.h"

@interface QuestionTableViewCell ()

@property (nonatomic, strong) UIView                *userInfoView;
@property (nonatomic, strong) UIView                *wtContentView;
@property (nonatomic, strong) UIView                *funcView;
@property (nonatomic, strong) UIView                *spaceView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) QuestionInfo          *questionInfo;
@property (nonatomic, strong) UserInfo              *userInfo;
@property (nonatomic, assign) BOOL                  haveUserInfo;

@property (nonatomic, assign) CGFloat               userInfoViewHeight;
@property (nonatomic, assign) CGFloat               wtContentViewHeight;
@property (nonatomic, assign) CGFloat               funcViewHeight;
@property (nonatomic, assign) CGFloat               spaceViewHeight;
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
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
        self.tapGesture = tap;
        
        [self layoutSpaceView:self.contentView];
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
            [_userInfoView setClipsToBounds:YES];
            [viewParent addSubview:_userInfoView];
        }
        
        UIImageView *photoImage = (UIImageView *)[_userInfoView viewWithTag:100];
        if (photoImage == nil) {
            photoImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            [photoImage setTag:100];
            [photoImage.layer setCornerRadius:20/2.0];
            [photoImage setClipsToBounds:YES];
            [_userInfoView addSubview:photoImage];
        }
    
        UILabel  *nameLabel = (UILabel *)[_userInfoView viewWithTag:101];
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [nameLabel setBackgroundColor:[UIColor clearColor]];
            [nameLabel setTag:101];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setTextColor:[UIColor grayColor]];
            [nameLabel setFont:[UIFont systemFontOfSize:14]];
            [_userInfoView addSubview:nameLabel];
        }
        
        UILabel  *levelLabel = (UILabel *)[_userInfoView viewWithTag:102];
        if (levelLabel == nil) {
            levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [levelLabel setBackgroundColor:[UIColor clearColor]];
            [levelLabel setTag:102];
            [levelLabel setTextAlignment:NSTextAlignmentCenter];
            [levelLabel setTextColor:[UIColor grayColor]];
            [levelLabel setFont:[UIFont systemFontOfSize:14]];
            [_userInfoView addSubview:levelLabel];
        }
        
        UIButton *attentionBtn = (UIButton *)[_userInfoView viewWithTag:QuestionTableViewCellAction_Attention];
        if (attentionBtn == nil) {
            attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [attentionBtn setTag:QuestionTableViewCellAction_Attention];
            [attentionBtn setImage:[UIImage imageNamed:@"attention"] forState:UIControlStateNormal];
            [attentionBtn addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
            [_userInfoView addSubview:attentionBtn];
        }
        
    
        CGFloat left = 10;
        CGFloat top = 10;
        [photoImage setFrame:CGRectMake(left, top, 20, 20)];
        
        if (_userInfo) {
            
            //取图片缓存
            SDImageCache * imageCache = [SDImageCache sharedImageCache];
            
            //从缓存取
            UIImage * cacheimage = [imageCache imageFromDiskCacheForKey:_userInfo.headImage];
            
            if (cacheimage == nil) {
                cacheimage = [UIImage imageNamed:@"defaultHeadImage"];
                
                [photoImage  sd_setImageWithURL:[NSURL URLWithString:_userInfo.headImage] placeholderImage:cacheimage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        photoImage.image = image;
                        [[SDImageCache sharedImageCache] storeImage:image forKey:_userInfo.headImage];
                    }
                }];
            } else {
                photoImage.image = cacheimage;
            }
        }
        
        left += 20 + 10;
        [nameLabel setFrame:CGRectMake(left, top, 180, 20)];
        if (_userInfo.nickName) {
            [nameLabel setText:_userInfo.nickName];
        } else {
            if (_userInfo.userName) {
                [nameLabel setText:_userInfo.userName];
            }
        }
        
        left += 180;
        [levelLabel setFrame:CGRectMake(left, top, (screenWidth - 2*left), 20)];
        if (_userInfo.level) {
            [levelLabel setText:[NSString stringWithFormat:@"%d级",[_userInfo.level intValue]]];
        }
        
        [attentionBtn setFrame:CGRectMake(screenWidth - 10 - 33, (40 - 17)/2.0, 33, 17)];
        
        //
        if (_haveUserInfo) {
            [_userInfoView setFrame:CGRectMake(0, _spaceViewHeight, self.frame.size.width, 40)];
            _userInfoViewHeight = 40;
        } else {
            [_userInfoView setFrame:CGRectZero];
            _userInfoViewHeight = 0;
        }
    }
}

// tag == 200
- (void)layoutWtContentView:(UIView *)viewParent {
    if (viewParent != nil) {
        
        if (self.wtContentView == nil) {
            self.wtContentView = [[UIView alloc] initWithFrame:CGRectZero];
            [_wtContentView setBackgroundColor:[UIColor whiteColor]];
            [_wtContentView setClipsToBounds:YES];
            [viewParent addSubview:_wtContentView];
        }
        

        // 语音播放按钮 200
        AudioPlayControl *audioControl = (AudioPlayControl *)[_wtContentView viewWithTag:QuestionTableViewCellAction_PlayAudio];
        if (audioControl == nil) {
            audioControl = [[AudioPlayControl alloc] initWithFrame:CGRectZero];
            [audioControl setTag:QuestionTableViewCellAction_PlayAudio];
            [audioControl addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
            [_wtContentView addSubview:audioControl];
        }

        // 图片 & 视频图片
        UIImageView *contentImage = (UIImageView *)[_wtContentView viewWithTag:201];
        if (contentImage == nil) {
            contentImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            [contentImage setContentMode:UIViewContentModeScaleAspectFill];
            [contentImage setClipsToBounds:YES];
            [contentImage setUserInteractionEnabled:YES];
            [contentImage setTag:201];
            [_wtContentView addSubview:contentImage];
        }
        
        // 视频播放按钮
        UIButton *playBtn = (UIButton*)[_wtContentView viewWithTag:QuestionTableViewCellAction_PlayVideo];
        if (playBtn == nil) {
            playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [playBtn setTag:QuestionTableViewCellAction_PlayVideo];
            [playBtn setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
        
            [playBtn addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
            [_wtContentView addSubview:playBtn];
        }
        
        //
        UILabel  *contentLabel = (UILabel *)[_wtContentView viewWithTag:203];
        if (contentLabel == nil) {
            contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [contentLabel setBackgroundColor:[UIColor clearColor]];
            [contentLabel setTag:203];
            [contentLabel setNumberOfLines:2];
            [contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [contentLabel setTextColor:[UIColor grayColor]];
            [contentLabel setFont:[UIFont systemFontOfSize:14]];
            [_wtContentView addSubview:contentLabel];
        }
        
        //0 图片，1 视频 ，2音频
        audioControl.hidden = YES;
        contentImage.hidden = YES;
        playBtn.hidden = YES;
        if ([contentImage.gestureRecognizers containsObject:_tapGesture]) {
            [contentImage removeGestureRecognizer:_tapGesture];
        }
        if ([_questionInfo.mediaType integerValue] == 0 || [_questionInfo.mediaType integerValue] == 1) {
            contentImage.hidden = NO;
            playBtn.hidden = ![_questionInfo.mediaType integerValue] == 1;
            
            if ([_questionInfo.mediaType integerValue] == 0) {
                [contentImage addGestureRecognizer:_tapGesture];
            }
            
            NSString *imageUrlString = [_questionInfo.mediaType integerValue] == 0 ? _questionInfo.mediaURL : _questionInfo.thumbnail;
            
            CGFloat left = 10;
            CGFloat top = 0;
            [contentImage setFrame:CGRectMake(left, top, 120, 120)];
            [playBtn setFrame:CGRectMake(left, top, 120, 120)];
            [playBtn setImageEdgeInsets:UIEdgeInsetsMake(30, 30, 30, 30)];
            
            //取图片缓存
            SDImageCache * imageCache = [SDImageCache sharedImageCache];
            
            //从缓存取
            UIImage * cacheimage = [imageCache imageFromDiskCacheForKey:imageUrlString];
            
            if (cacheimage == nil) {
//                cacheimage = [UIImage imageNamed:nil];
                
                [contentImage  sd_setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:cacheimage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (image) {
                        contentImage.image = image;
                        [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrlString];
                    }
                }];
            } else {
                contentImage.image = cacheimage;
            }
            
            top += 120;
            [contentLabel setFrame:CGRectMake(left, top, screenWidth - 20, 45)];
            [contentLabel setText:_questionInfo.content];
            
            _wtContentViewHeight = 120 + 45;
        } else if ([_questionInfo.mediaType integerValue] == 2) {
            audioControl.hidden = NO;
            [audioControl.timeLabel setText:[NSString stringWithFormat:@"%d\"",[_questionInfo.duration intValue]]];
            CGFloat left = 10;
            CGFloat top = 0;
            [audioControl setFrame:CGRectMake(left, top, screenWidth - 20, 55)];
            
            top += 55;
            [contentLabel setFrame:CGRectMake(left, top, screenWidth - 20, 45)];
            [contentLabel setText:_questionInfo.content];
            
            _wtContentViewHeight = 55 + 45;
        }
        
        [_wtContentView setFrame:CGRectMake(0, _userInfoViewHeight + _spaceViewHeight, self.frame.size.width, _wtContentViewHeight)];
    }
}


// tag == 300
- (void)layoutFuncView:(UIView *)viewParent {
    
    if (viewParent != nil) {
        
        if (self.funcView == nil) {
            self.funcView = [[UIView alloc] initWithFrame:CGRectZero];
            [_funcView setBackgroundColor:[UIColor whiteColor]];
            [viewParent addSubview:_funcView];
        }
        
        
        UILabel  *locationLabel = (UILabel *)[_funcView viewWithTag:300];
        if (locationLabel == nil) {
            locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [locationLabel setBackgroundColor:[UIColor clearColor]];
            [locationLabel setTag:300];
            [locationLabel setTextColor:[UIColor grayColor]];
            [locationLabel setFont:[UIFont systemFontOfSize:10]];
            [_funcView addSubview:locationLabel];
        }
        
        //
        UIButton *typeBtn = (UIButton*)[_funcView viewWithTag:301];
        if (typeBtn == nil) {
            typeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [typeBtn setTag:301];
            UIImage *image = [UIImage imageNamed:@"category"];
            [typeBtn setImage:image forState:UIControlStateNormal];
            [typeBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [typeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [typeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width/2.0 + 6, 0, 0)];
            [_funcView addSubview:typeBtn];
        }
        
        LineView *line1 = (LineView *)[_funcView viewWithTag:302];
        if (line1 == nil) {
            line1 = [[LineView alloc] initWithFrame:CGRectZero];
            [line1 setTag:302];
            [_funcView addSubview:line1];
        }
        
        
//        LineView *line2 = (LineView *)[_funcView viewWithTag:303];
//        if (line2 == nil) {
//            line2 = [[LineView alloc] initWithFrame:CGRectZero];
//            [line2 setTag:303];
//            [_funcView addSubview:line2];
//        }
//
//        UILabel  *answerLabel = (UILabel *)[_funcView viewWithTag:304];
//        if (answerLabel == nil) {
//            answerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//            [answerLabel setBackgroundColor:[UIColor clearColor]];
//            [answerLabel setTag:304];
//            [answerLabel setTextColor:[UIColor colorWithHex:0xcccccc]];
//            [answerLabel setFont:[UIFont systemFontOfSize:10]];
//            [_funcView addSubview:answerLabel];
//        }
        
        //
        UIButton *rewardBtn = (UIButton*)[_funcView viewWithTag:305];
        if (rewardBtn == nil) {
            rewardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [rewardBtn setTag:305];
            UIImage *image = [UIImage imageNamed:@"reward"];
            [rewardBtn setImage:image forState:UIControlStateNormal];
            [rewardBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [rewardBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [rewardBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width/2.0 + 6, 0, 0)];
            [_funcView addSubview:rewardBtn];
        }
        
        LineView *line3 = (LineView *)[_funcView viewWithTag:306];
        if (line3 == nil) {
            line3 = [[LineView alloc] initWithFrame:CGRectZero];
            [line3 setTag:306];
            [_funcView addSubview:line3];
        }
        
        UILabel  *timeLabel = (UILabel *)[_funcView viewWithTag:307];
        if (timeLabel == nil) {
            timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setTag:307];
            [timeLabel setTextColor:[UIColor grayColor]];
            [timeLabel setFont:[UIFont systemFontOfSize:10]];
            [_funcView addSubview:timeLabel];
        }
        
        UIButton *answerBtn = (UIButton*)[_funcView viewWithTag:QuestionTableViewCellAction_Answer];
        if (answerBtn == nil) {
            answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [answerBtn setTag:QuestionTableViewCellAction_Answer];
            UIImage *image = [UIImage imageNamed:@"answer"];
            [answerBtn setImage:image forState:UIControlStateNormal];
            [answerBtn addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
            [_funcView addSubview:answerBtn];
        }
        
        UIButton *sharingBtn = (UIButton*)[_funcView viewWithTag:QuestionTableViewCellAction_Sharing];
        if (sharingBtn == nil) {
            sharingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [sharingBtn setTag:QuestionTableViewCellAction_Sharing];
            UIImage *image = [UIImage imageNamed:@"sharing"];
            [sharingBtn setImage:image forState:UIControlStateNormal];
            [sharingBtn addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
            [_funcView addSubview:sharingBtn];
        }
        
        // 20 - 40 设置高度
        CGFloat left = 10;
        CGFloat top = 0;
        if (_questionInfo.address) {
            [locationLabel setText:_questionInfo.address];
            [locationLabel setFrame:CGRectMake(left, top, 150, 20)];
        }
        
        CGSize sizeText1 = [_questionInfo.reward sizeWithFontCompatible:rewardBtn.titleLabel.font constrainedToSize:CGSizeMake(0, CGFLOAT_MAX) lineBreakMode:rewardBtn.titleLabel.lineBreakMode];
        if (_questionInfo.reward) {
            [rewardBtn setTitle:_questionInfo.reward forState:UIControlStateNormal];
            
            UIImage *image = [UIImage imageNamed:@"reward"];
            left = screenWidth - 10 - image.size.width/2.0 - sizeText1.width - 6;
            [rewardBtn setFrame:CGRectMake(left, top, image.size.width + sizeText1.width + 6, 20)];
            
            left -= 10;
            [line1 setFrame:CGRectMake(left, 5, kLineHeight1px, 10)];
        }
        
        if (_questionInfo.type) {
            [typeBtn setTitle:_questionInfo.type forState:UIControlStateNormal];
            UIImage *image = [UIImage imageNamed:@"category"];
            CGSize sizeText = [_questionInfo.type sizeWithFontCompatible:typeBtn.titleLabel.font constrainedToSize:CGSizeMake(0, CGFLOAT_MAX) lineBreakMode:typeBtn.titleLabel.lineBreakMode];
            
            left -= image.size.width/2.0 + sizeText.width + sizeText1.width + 6;
            [typeBtn setFrame:CGRectMake(left, top, image.size.width + sizeText.width + 6, 20)];
        }
        
        top += 20;
        [line3 setFrame:CGRectMake(0, top, screenWidth, kLineHeight1px)];
        
        //
        if (_questionInfo.updateDate) {
            left = 10;
            [timeLabel setText:_questionInfo.updateDate];
            [timeLabel setFrame:CGRectMake(left, top, 120, 40)];
        }
        
        left = screenWidth - 10 - 33;
        [sharingBtn setFrame:CGRectMake(left, top + (40 - 17)/2.0, 33, 17)];
        
        left -= 20+ 33;
        [answerBtn setFrame:CGRectMake(left, top + (40 - 17)/2.0,  33, 17)];
        
        _funcViewHeight = 60;
        
        [_funcView setFrame:CGRectMake(0, _userInfoViewHeight + _wtContentViewHeight + _spaceViewHeight, self.frame.size.width, _funcViewHeight)];
    }
}

- (void)layoutSpaceView:(UIView *)viewParent {
    
    if (viewParent != nil) {
        
        if (self.spaceView == nil) {
            self.spaceView = [[UIView alloc] initWithFrame:CGRectZero];
            [_spaceView setBackgroundColor:[UIColor colorWithHex:0xebeef0]];
            [viewParent addSubview:_spaceView];
        }
        
        [_spaceView setFrame:CGRectMake(0, 0, self.frame.size.width, 12)];
        _spaceViewHeight = 12;
    }
}

- (void)tapPhotoAction:(UITapGestureRecognizer *)sender {
    UIImageView *senderImageView = (UIImageView*)sender.view;
    
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    [imageViewer showWithImageViews:[NSArray arrayWithObject:senderImageView] selectedView:senderImageView];
}

- (void)cellAction:(UIControl*)sender {
    QuestionTableViewCellAction tag = sender.tag;
    
    if (tag == QuestionTableViewCellAction_Attention) {
        //关注
    } else if (tag == QuestionTableViewCellAction_PlayAudio) {
        //语音播放
        [(AudioPlayControl*)sender startPlayAnimation];
    } else if (tag == QuestionTableViewCellAction_PlayVideo) {
        //视频播放
    } else if (tag == QuestionTableViewCellAction_Answer) {
        //回答
    } else if (tag == QuestionTableViewCellAction_Sharing) {
        
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(questionTableViewCellAction:questionInfo:)]) {
        [_delegate questionTableViewCellAction:tag questionInfo:_questionInfo];
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
    _spaceViewHeight = 0;
    
    self.questionInfo = questionInfo;
    self.userInfo = userInfo;
    [self layoutSpaceView:self.contentView];
    [self layoutUserView:self.contentView];
    [self layoutWtContentView:self.contentView];
    [self layoutFuncView:self.contentView];
    
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, [self cellHeight]);
}

- (CGFloat)cellHeight {
    return _userInfoViewHeight + _wtContentViewHeight + _funcViewHeight + _spaceViewHeight;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutSpaceView:self.contentView];
    [self layoutUserView:self.contentView];
    [self layoutWtContentView:self.contentView];
    [self layoutFuncView:self.contentView];
   
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, [self cellHeight]);
}

@end
