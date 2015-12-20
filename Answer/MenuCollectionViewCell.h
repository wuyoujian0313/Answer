//
//  MenuCollectionViewCell.h
//  PluginApp
//
//  Created by wuyj on 15-1-6.
//  Copyright (c) 2015年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MenuCollectionViewIdentifier          @"MenuCollectionViewIdentifier"


@interface MenuCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong) UIImageView             *menuImageView;
@property(nonatomic,strong) UILabel                 *nameLabel;
@property(nonatomic,copy) NSIndexPath               *indexPath;

-(void)setImageName:(NSString *)imageName withName:(NSString*)name;

@end
