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
    [self.imageView setFrame:CGRectMake(0, 0, 50, 50)];
    CGRect frame1 = self.textLabel.frame;
    [self.textLabel setFrame:CGRectMake(50, frame1.origin.y, frame1.size.width, frame1.size.height)];
    CGRect frame2 = self.detailTextLabel.frame;
    [self.detailTextLabel setFrame:CGRectMake(50, frame2.origin.y, frame2.size.width, frame2.size.height)];
    [self.accessoryView setFrame:CGRectMake(self.frame.size.width - 50, 0, 50, 50)];
}

@end
