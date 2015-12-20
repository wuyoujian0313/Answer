//
//  MenuCollectionViewCell.m
//  PluginApp
//
//  Created by wuyj on 15-1-6.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import "MenuCollectionViewCell.h"
#import "LineView.h"

@interface MenuCollectionViewCell ()
@property(nonatomic,strong) LineView            *lineH;
@property(nonatomic,strong) LineView            *lineV;
@end


@implementation MenuCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.menuImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 50)/2.0, (self.frame.size.height - 50 - 10 - 14)/2.0, 50, 50)];
        _menuImageView.userInteractionEnabled = YES;
        _menuImageView.clipsToBounds = YES;
        [self.contentView addSubview:_menuImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(self.frame.size.height - 50 - 10 - 14)/2.0 +50 + 10, self.contentView.frame.size.width, 14)];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [_nameLabel setTextColor:[UIColor colorWithHex:0x5e5f62]];
        [self.contentView addSubview:_nameLabel];
        
        
        self.lineH = [[LineView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - kLineHeight1px, self.bounds.size.width, kLineHeight1px)];
        [self.contentView addSubview:_lineH];
        
        self.lineV = [[LineView alloc] initWithFrame:CGRectMake(self.bounds.size.width - kLineHeight1px, 0, kLineHeight1px, self.bounds.size.height)];
        [self.contentView addSubview:_lineV];
        
    }
    return self;
}

-(void)setImageName:(NSString *)imageName withName:(NSString*)name {
    _nameLabel.text = name;
    _menuImageView.image = [UIImage imageNamed:imageName];
}

@end
