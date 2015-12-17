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

@interface QuestionTableViewCell ()

@property (nonatomic, strong) UIView                *userInfoView;
@property (nonatomic, strong) UIView                *wtContentView;
@property (nonatomic, strong) UIView                *funcView;
@property (nonatomic, strong) QuestionInfo          *questionInfo;
@property (nonatomic, strong) UserInfo              *userInfo;
@property (nonatomic, assign) BOOL                  haveUserInfo;

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
        
        
        
    } else {
        
    }
}

- (void)layoutWtContentView:(UIView *)viewParent {
    
}

- (void)layoutFuncView:(UIView *)viewParent {
    
}

- (void)setQuestionInfo:(QuestionInfo*)questionInfo userInfo:(UserInfo*)userInfo {
    
    if (userInfo) {
        
    }
    
    [self layoutUserView:self.contentView];
    [self layoutWtContentView:self.contentView];
    [self layoutFuncView:self.contentView];
    
    
    
}

- (CGFloat)cellHeight {
    return 0;
}

@end
