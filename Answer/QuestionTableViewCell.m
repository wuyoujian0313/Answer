//
//  QuestionTableViewCell.m
//  Answer
//
//  Created by wuyj on 15/12/16.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionTableViewCell.h"

@implementation QuestionTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier haveUserView:YES];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier haveUserView:(BOOL)isHave {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        
    }
    
    return self;
}



- (CGFloat)cellHeight {
    return 0;
}

@end
