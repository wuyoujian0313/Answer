//
//  AnswerTableViewCell.m
//  Answer
//
//  Created by wuyj on 15/12/30.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "AnswerTableViewCell.h"

@implementation AnswerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView.layer setCornerRadius:4];
    [self.imageView setClipsToBounds:YES];
    [self.imageView setFrame:CGRectMake(10, 10, 30, 30)];
    [self.textLabel setFrame:CGRectMake(50, 0, self.frame.size.width - 60, self.frame.size.height)];
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    [self.textLabel setNumberOfLines:0];
    self.detailTextLabel.hidden = YES;
}

@end