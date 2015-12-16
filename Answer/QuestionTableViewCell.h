//
//  QuestionTableViewCell.h
//  Answer
//
//  Created by wuyj on 15/12/16.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol QuestionTableViewCellDelegate <NSObject>
@end

@interface QuestionTableViewCell : UITableViewCell

@property(nonatomic,weak) id <QuestionTableViewCellDelegate> delegate;

// 默认布局用户信息
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier haveUserView:(BOOL)isHave;



- (CGFloat)cellHeight;

@end
