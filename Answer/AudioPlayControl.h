//
//  AudioPlayControl.h
//  Answer
//
//  Created by wuyj on 15/12/17.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define stopPlayAudioNotification   @"stopPlayAudioNotification"

@interface AudioPlayControl : UIControl
@property (nonatomic, strong) UILabel       *timeLabel;


- (void)startPlayAnimation;
- (void)stopPlayAnimation;

@end
