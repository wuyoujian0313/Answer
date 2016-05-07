//
//  MessageTableViewCell.m
//  Answer
//
//  Created by wuyoujian on 16/5/7.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    [self.imageView setHidden:YES];
    [self.detailTextLabel setHidden:YES];
    
    [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.textLabel setFont:[UIFont systemFontOfSize:14]];
    [self.textLabel setNumberOfLines:0];
}


@end
