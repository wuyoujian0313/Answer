//
//  QuestionInfoView.m
//  Answer
//
//  Created by wuyj on 15/12/29.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionInfoView.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "TTTTimeIntervalFormatter.h"
#import "AudioPlayControl.h"
#import "LineView.h"
#import "XHImageViewer.h"
#import "User.h"

@interface QuestionInfoView ()
@property (nonatomic, strong) UIView                *userInfoView;
@property (nonatomic, strong) UIView                *wtContentView;
@property (nonatomic, strong) UIView                *funcView;
@property (nonatomic, strong) UIView                *spaceView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) QuestionInfo          *questionInfo;
@property (nonatomic, assign) BOOL                  haveUserInfo;
@property (nonatomic, assign) BOOL                  isFoldText;

@property (nonatomic, assign) CGFloat               userInfoViewHeight;
@property (nonatomic, assign) CGFloat               wtContentViewHeight;
@property (nonatomic, assign) CGFloat               funcViewHeight;
@property (nonatomic, assign) CGFloat               spaceViewHeight;
@end

@implementation QuestionInfoView

- (void)dealloc {
    [_tapGesture.view removeGestureRecognizer:_tapGesture];
}

+ (QuestionInfoView *)sharedQuestionInfoView {
    
    static QuestionInfoView *sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[self alloc] init];
    });
    return sharedObj;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //
        self.haveUserInfo = NO;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
        self.tapGesture = tap;
        
        [self layoutSpaceView:self];
        [self layoutUserView:self];
        [self layoutWtContentView:self];
        [self layoutFuncView:self];
    }
    
    return self;
}

- (void)hiddenAttentBtn {
    UIButton *attentionBtn = (UIButton *)[_userInfoView viewWithTag:QuestionInfoViewAction_Attention];
    if ([attentionBtn isKindOfClass:[UIButton class]]) {
        attentionBtn.hidden = YES;
    }
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
            [photoImage.layer setCornerRadius:30/2.0];
            [photoImage setClipsToBounds:YES];
            [_userInfoView addSubview:photoImage];
        }
        
//        UILabel  *levelLabel = (UILabel *)[_userInfoView viewWithTag:102];
//        if (levelLabel == nil) {
//            levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//            [levelLabel setBackgroundColor:[UIColor whiteColor]];
//            [levelLabel setTag:102];
//            [levelLabel setTextAlignment:NSTextAlignmentCenter];
//            [levelLabel setTextColor:[UIColor grayColor]];
//            [levelLabel setFont:[UIFont systemFontOfSize:14]];
//            [_userInfoView addSubview:levelLabel];
//        }
//        
//        //
//        levelLabel.hidden = YES;
        
        UILabel  *nameLabel = (UILabel *)[_userInfoView viewWithTag:101];
        if (nameLabel == nil) {
            nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [nameLabel setBackgroundColor:[UIColor whiteColor]];
            [nameLabel setTag:101];
            [nameLabel setTextAlignment:NSTextAlignmentLeft];
            [nameLabel setTextColor:[UIColor grayColor]];
            [nameLabel setFont:[UIFont systemFontOfSize:14]];
            [_userInfoView addSubview:nameLabel];
        }
        
        UIButton *attentionBtn = (UIButton *)[_userInfoView viewWithTag:QuestionInfoViewAction_Attention];
        if (attentionBtn == nil) {
            attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [attentionBtn setTag:QuestionInfoViewAction_Attention];
            [attentionBtn setImage:[UIImage imageNamed:@"attention"] forState:UIControlStateNormal];
            [attentionBtn addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
            [_userInfoView addSubview:attentionBtn];
        }
        
        
        CGFloat left = 10;
        CGFloat top = 5;
        [photoImage setFrame:CGRectMake(left, top, 30, 30)];
        
        photoImage.image = nil;
        if (_questionInfo.userId) {
            if (_questionInfo.isAnonymous && [_questionInfo.isAnonymous isEqualToString:@"1"]) {
                photoImage.image = [UIImage imageNamed:@"defaultHeadImage"];
            } else {
                //取图片缓存
                __weak UIImageView *wPhotoImage = photoImage;
                SDImageCache * imageCache = [SDImageCache sharedImageCache];
                
                //从缓存取
                NSString *imageUrl = _questionInfo.headImage;
                if (imageUrl && [imageUrl length] > 0) {
                    UIImage * cacheimage = [imageCache imageFromDiskCacheForKey:imageUrl];
                    
                    if (cacheimage == nil) {
                        cacheimage = [UIImage imageNamed:@"defaultHeadImage"];
                        
                        [photoImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:cacheimage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if (image) {
                                UIImageView *sPhotoImage = wPhotoImage;
                                [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrl];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    sPhotoImage.image = image;
                                });
                            }
                        }];
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImageView *sPhotoImage = wPhotoImage;
                            sPhotoImage.image = cacheimage;
                        });
                    }
                }
            }
        }
        
        left += 30 + 10;
        [nameLabel setFrame:CGRectMake(left, top, 180, 30)];
        
        if (_questionInfo.isAnonymous && [_questionInfo.isAnonymous isEqualToString:@"1"]) {
            [nameLabel setText:@"匿名"];
        } else {
            if (_questionInfo.nickName && [_questionInfo.nickName length]) {
                [nameLabel setText:_questionInfo.nickName];
            } else {
                if (_questionInfo.phoneNumber && [_questionInfo.phoneNumber length]) {
                    [nameLabel setText:_questionInfo.phoneNumber];
                } else {
                    [nameLabel setText:@"匿名"];
                }
            }
        }
        
        left += 180;
//        [levelLabel setFrame:CGRectMake(left, top, (self.frame.size.width - 2*left), 20)];
//        if (_userInfo.level && [_userInfo.level length]) {
//            [levelLabel setText:[NSString stringWithFormat:@"%@级",_userInfo.level]];
//        }
        
        if ([[User sharedUser] isMe:_questionInfo.userId]) {
            attentionBtn.hidden = YES;
        } else {
            if (![[User sharedUser] isFriend:_questionInfo.userId]) {
                [attentionBtn setImageEdgeInsets:UIEdgeInsetsMake((40-17)/2.0, 0, (40-17)/2.0, 40-33)];
                [attentionBtn setFrame:CGRectMake(self.frame.size.width - 43, 0, 40, 40)];
                attentionBtn.hidden = NO;
            } else {
                attentionBtn.hidden = YES;
            }
        }
        

        //
        if (_haveUserInfo) {
            [_userInfoView setFrame:CGRectMake(0, _spaceViewHeight, self.frame.size.width, 40)];
            _userInfoViewHeight = 40;
        } else {
            [_userInfoView setFrame:CGRectZero];
            _userInfoViewHeight = 0;
        }
    } else {
        
        //
        if (_haveUserInfo) {
            _userInfoViewHeight = 40;
        } else {
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
        AudioPlayControl *audioControl = (AudioPlayControl *)[_wtContentView viewWithTag:QuestionInfoViewAction_PlayAudio];
        if (audioControl == nil) {
            audioControl = [[AudioPlayControl alloc] initWithFrame:CGRectZero];
            [audioControl setTag:QuestionInfoViewAction_PlayAudio];
            [audioControl addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
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
        UIButton *playBtn = (UIButton*)[_wtContentView viewWithTag:QuestionInfoViewAction_PlayVideo];
        if (playBtn == nil) {
            playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [playBtn setTag:QuestionInfoViewAction_PlayVideo];
            [playBtn setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
            
            [playBtn addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
            [_wtContentView addSubview:playBtn];
        }
        
        //
        UILabel  *contentLabel = (UILabel *)[_wtContentView viewWithTag:203];
        if (contentLabel == nil) {
            contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [contentLabel setBackgroundColor:[UIColor whiteColor]];
            [contentLabel setTag:203];
            [contentLabel setTextColor:[UIColor grayColor]];
            [contentLabel setFont:[UIFont systemFontOfSize:14]];
            [_wtContentView addSubview:contentLabel];
        }
        
        //2 图片，1 视频 ，0音频
        audioControl.hidden = YES;
        contentImage.hidden = YES;
        playBtn.hidden = YES;
        if ([contentImage.gestureRecognizers containsObject:_tapGesture]) {
            [contentImage removeGestureRecognizer:_tapGesture];
        }
        if (_questionInfo.mediaType && ([_questionInfo.mediaType integerValue] == 1 || [_questionInfo.mediaType integerValue] == 2)) {
            contentImage.hidden = NO;
            playBtn.hidden = !([_questionInfo.mediaType integerValue] == 1);
            
            if ([_questionInfo.mediaType integerValue] == 2) {
                [contentImage addGestureRecognizer:_tapGesture];
            }
            
            NSString *imageUrlString = [_questionInfo.mediaType integerValue] == 2 ? _questionInfo.mediaURL : _questionInfo.thumbnail;
            CGFloat left = 10;
            CGFloat top = 5;
            [contentImage setFrame:CGRectMake(left, top, 120, 120)];
            [playBtn setFrame:CGRectMake(left, top, 120, 120)];
            [playBtn setImageEdgeInsets:UIEdgeInsetsMake(30, 30, 30, 30)];
            
            
            contentImage.image = nil;
            __weak UIImageView *wContentImage = contentImage;
            //取图片缓存
            SDImageCache * imageCache = [SDImageCache sharedImageCache];
            
            
            //从缓存取
            if (imageUrlString && [imageUrlString length] > 0) {
                UIImage * cacheimage = [imageCache imageFromDiskCacheForKey:imageUrlString];
                
                if (cacheimage == nil) {
                    cacheimage = [UIImage imageFromColor:[UIColor colorWithHex:0xcccccc]];
                    [contentImage sd_setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:cacheimage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        if (image) {
                            
                            UIImageView *sContentImage = wContentImage;
                            [[SDImageCache sharedImageCache] storeImage:image forKey:imageUrlString];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                sContentImage.image = image;
                            });
                            
                        }
                    }];
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImageView *sContentImage = wContentImage;
                        sContentImage.image = cacheimage;
                    });
                }
            }
            
            
            top += 120;
            
            [contentLabel setText:_questionInfo.content];
            if (_isFoldText) {
                [contentLabel setNumberOfLines:2];
                [contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
                [contentLabel setFrame:CGRectMake(left, top, self.frame.size.width - 20, 45)];
                
                _wtContentViewHeight = top + 45;
            } else {
                
                [contentLabel setNumberOfLines:0];
                [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
                
                CGSize textSize = [contentLabel.text sizeWithFontCompatible:contentLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX) lineBreakMode:contentLabel.lineBreakMode];
                
                [contentLabel setFrame:CGRectMake(left, top + 10, textSize.width, textSize.height)];
                _wtContentViewHeight = top + textSize.height + 20;
            }
            
        } else if (_questionInfo.mediaType && [_questionInfo.mediaType integerValue] == 0) {
            audioControl.hidden = NO;
            [audioControl.timeLabel setText:[NSString stringWithFormat:@"%d\"",[_questionInfo.mediaLen intValue]]];
            CGFloat left = 10;
            CGFloat top = 5;
            [audioControl setFrame:CGRectMake(left, top, 80, 55)];
            
            top += 55;
            [contentLabel setText:_questionInfo.content];
            if (_isFoldText) {
                [contentLabel setNumberOfLines:2];
                [contentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
                [contentLabel setFrame:CGRectMake(left, top, self.frame.size.width - 20, 45)];
                
                _wtContentViewHeight = top + 45;
            } else {
                
                [contentLabel setNumberOfLines:0];
                [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
                
                CGSize textSize = [contentLabel.text sizeWithFontCompatible:contentLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX) lineBreakMode:contentLabel.lineBreakMode];
                
                [contentLabel setFrame:CGRectMake(left, top + 10, textSize.width, textSize.height)];
                _wtContentViewHeight = top + textSize.height + 20;
            }
        }
        
        [_wtContentView setFrame:CGRectMake(0, _userInfoViewHeight + _spaceViewHeight, self.frame.size.width, _wtContentViewHeight)];
    } else {
        
        if (_questionInfo.mediaType && ([_questionInfo.mediaType integerValue] == 1 || [_questionInfo.mediaType integerValue] == 2)) {
            
            CGFloat top = 5;

            top += 120;
        
            if (_isFoldText) {
                _wtContentViewHeight = top + 45;
            } else {
                CGSize textSize = [_questionInfo.content sizeWithFontCompatible:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            
                _wtContentViewHeight = top + textSize.height + 20;
            }
            
        } else if (_questionInfo.mediaType && [_questionInfo.mediaType integerValue] == 0) {
    
            CGFloat top = 5;
            top += 55;
            if (_isFoldText) {
                _wtContentViewHeight = top + 45;
            } else {
                CGSize textSize = [_questionInfo.content sizeWithFontCompatible:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.frame.size.width - 20, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
                _wtContentViewHeight = top + textSize.height + 20;
            }
        }
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
            [locationLabel setBackgroundColor:[UIColor whiteColor]];
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
            [typeBtn setEnabled:NO];
            UIImage *image = [UIImage imageNamed:@"category"];
            [typeBtn setImage:image forState:UIControlStateNormal];
            [typeBtn setImage:image forState:UIControlStateDisabled];
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
            [rewardBtn setEnabled:NO];
            UIImage *image = [UIImage imageNamed:@"reward"];
            [rewardBtn setImage:image forState:UIControlStateNormal];
            [rewardBtn setImage:image forState:UIControlStateDisabled];
            [rewardBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [rewardBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [rewardBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width/2.0 + 6, 0, 0)];
            [_funcView addSubview:rewardBtn];
        }
        
        
        
        UILabel  *timeLabel = (UILabel *)[_funcView viewWithTag:307];
        if (timeLabel == nil) {
            timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [timeLabel setBackgroundColor:[UIColor whiteColor]];
            [timeLabel setTag:307];
            [timeLabel setTextColor:[UIColor grayColor]];
            [timeLabel setFont:[UIFont systemFontOfSize:10]];
            [_funcView addSubview:timeLabel];
        }
        
        LineView *line3 = (LineView *)[_funcView viewWithTag:306];
        if (line3 == nil) {
            line3 = [[LineView alloc] initWithFrame:CGRectZero];
            [line3 setTag:306];
            [_funcView addSubview:line3];
        }
        
        UIButton *answerBtn = (UIButton*)[_funcView viewWithTag:QuestionInfoViewAction_Answer];
        if (answerBtn == nil) {
            answerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [answerBtn setTag:QuestionInfoViewAction_Answer];
            UIImage *image = [UIImage imageNamed:@"answer"];
            [answerBtn setImage:image forState:UIControlStateNormal];
            [answerBtn addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
            [_funcView addSubview:answerBtn];
        }
        
        UIButton *sharingBtn = (UIButton*)[_funcView viewWithTag:QuestionInfoViewAction_Sharing];
        if (sharingBtn == nil) {
            sharingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [sharingBtn setTag:QuestionInfoViewAction_Sharing];
            UIImage *image = [UIImage imageNamed:@"sharing"];
            [sharingBtn setImage:image forState:UIControlStateNormal];
            [sharingBtn addTarget:self action:@selector(viewAction:) forControlEvents:UIControlEventTouchUpInside];
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
            left = self.frame.size.width - 10 - image.size.width/2.0 - sizeText1.width - 6;
            [rewardBtn setFrame:CGRectMake(left, top, image.size.width + sizeText1.width + 6, 20)];
            
            left -= 10;
            [line1 setFrame:CGRectMake(left, 5, kLineHeight1px, 10)];
        }
        
        if (_questionInfo.fenlei) {
            [typeBtn setTitle:_questionInfo.fenlei forState:UIControlStateNormal];
            UIImage *image = [UIImage imageNamed:@"category"];
            CGSize sizeText = [_questionInfo.fenlei sizeWithFontCompatible:typeBtn.titleLabel.font constrainedToSize:CGSizeMake(0, CGFLOAT_MAX) lineBreakMode:typeBtn.titleLabel.lineBreakMode];
            
            left -= image.size.width/2.0 + sizeText.width + sizeText1.width + 6;
            [typeBtn setFrame:CGRectMake(left, top, image.size.width + sizeText.width + 6, 20)];
        }
        
        top += 20;
        [line3 setFrame:CGRectMake(0, top, self.frame.size.width, kLineHeight1px)];
        
        //
        if (_questionInfo.updateDate) {
            left = 10;
            NSString *timeString = _questionInfo.updateDate;
            NSDate *last = [NSDate dateWithTimeIntervalSince1970:[timeString longLongValue]/1000];
            NSTimeInterval timeInterval = [last timeIntervalSinceNow];
            
            TTTTimeIntervalFormatter *formatter = [[TTTTimeIntervalFormatter alloc] init];
            [formatter setLocale:[NSLocale currentLocale]];
            [formatter setUsesIdiomaticDeicticExpressions:NO];
            [formatter setUsesAbbreviatedCalendarUnits:NO];
            
            [timeLabel setText:[formatter stringForTimeInterval:timeInterval]];
            [timeLabel setFrame:CGRectMake(left, top, 120, 40)];
        }
        
        left = self.frame.size.width - 10 - 33;
        [sharingBtn setImageEdgeInsets:UIEdgeInsetsMake((40-17)/2.0, 0, (40-17)/2.0, 40-33)];
        [sharingBtn setFrame:CGRectMake(left, top, 40, 40)];
        
        left -= 20+ 33;
        if (!_isFoldText) {
            answerBtn.hidden = YES;
        } else {
            answerBtn.hidden = NO;
            [answerBtn setImageEdgeInsets:UIEdgeInsetsMake((40-17)/2.0, 0, (40-17)/2.0, 40-33)];
            [answerBtn setFrame:CGRectMake(left, top, 40, 40)];
        }
        
        
        _funcViewHeight = 60;
        
        [_funcView setFrame:CGRectMake(0, _userInfoViewHeight + _wtContentViewHeight + _spaceViewHeight, self.frame.size.width, _funcViewHeight)];
    } else {
        
        // 20 - 40 设置高度
        _funcViewHeight = 60;
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
    } else {
        _spaceViewHeight = 12;
    }
}

- (void)tapPhotoAction:(UITapGestureRecognizer *)sender {
    UIImageView *senderImageView = (UIImageView*)sender.view;
    
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    [imageViewer showWithImageViews:[NSArray arrayWithObject:senderImageView] selectedView:senderImageView];
}

- (void)viewAction:(UIControl*)sender {
    QuestionInfoViewAction tag = sender.tag;
    
    if (tag == QuestionInfoViewAction_Attention) {
        //关注
    } else if (tag == QuestionInfoViewAction_PlayAudio) {
        //语音播放
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
        [(AudioPlayControl*)sender startPlayAnimation];
    } else if (tag == QuestionInfoViewAction_PlayVideo) {
        //视频播放
    } else if (tag == QuestionInfoViewAction_Answer) {
        //回答
    } else if (tag == QuestionInfoViewAction_Sharing) {
        
    }
    
    
    if (_delegate && [_delegate respondsToSelector:@selector(questionInfoViewAction:questionInfo:)]) {
        [_delegate questionInfoViewAction:tag questionInfo:_questionInfo];
    }
}

- (void)setQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave isFoldText:(BOOL)isfold {
    
    _isFoldText = isfold;
    _userInfoViewHeight = 0;
    _wtContentViewHeight = 0;
    _funcViewHeight = 0;
    _spaceViewHeight = 0;
    
    self.questionInfo = questionInfo;
    
    [self layoutSpaceView:self];
    if (isHave) {
        _haveUserInfo = YES;
        [self layoutUserView:self];
    } else {
        _haveUserInfo = NO;
    }
    
    [self layoutWtContentView:self];
    [self layoutFuncView:self];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [self viewHeight]);
}

- (CGFloat)viewHeightByQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave isFoldText:(BOOL)isfold {
    
    
    _isFoldText = isfold;
    _userInfoViewHeight = 0;
    _wtContentViewHeight = 0;
    _funcViewHeight = 0;
    _spaceViewHeight = 0;
    
    [self layoutSpaceView:nil];
    self.questionInfo = questionInfo;
    if (isHave) {
        _haveUserInfo = YES;
        [self layoutUserView:nil];
    } else {
        _haveUserInfo = NO;
    }
    
    
    [self layoutWtContentView:nil];
    [self layoutFuncView:nil];
    
    return [self viewHeight];
}

- (void)setQuestionInfo:(QuestionInfo*)questionInfo haveUserView:(BOOL)isHave {
    [self setQuestionInfo:questionInfo haveUserView:isHave isFoldText:YES];
}

- (CGFloat)viewHeight {
    return _userInfoViewHeight + _wtContentViewHeight + _funcViewHeight + _spaceViewHeight;
}

//- (void)layoutSubviews {
//    
//    [super layoutSubviews];
//    [self layoutSpaceView:nil];
//    [self layoutUserView:nil];
//    [self layoutWtContentView:nil];
//    [self layoutFuncView:nil];
//
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [self viewHeight]);
//}


@end
