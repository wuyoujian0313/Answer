//
//  FriendTableViewCell.m
//  Answer
//
//  Created by wuyj on 15/12/22.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "FriendTableViewCell.h"

@implementation FriendTableViewCell

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
    [self.textLabel setFrame:CGRectMake(50, 0, self.frame.size.width - 50 - 60, self.frame.size.height)];
    self.detailTextLabel.hidden = YES;
    [self.accessoryView setFrame:CGRectMake(self.frame.size.width - 60, 0, 50, 50)];
}

@end
