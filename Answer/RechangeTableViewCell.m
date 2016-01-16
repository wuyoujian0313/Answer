//
//  RechangeTableViewCell.m
//  Answer
//
//  Created by wuyj on 16/1/16.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "RechangeTableViewCell.h"

@implementation RechangeTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.accessoryView setFrame:CGRectMake(self.frame.size.width - 50, 0, 50, 50)];
}

@end
