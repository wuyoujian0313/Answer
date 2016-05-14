//
//  AudioPlayControl.m
//  Answer
//
//  Created by wuyj on 15/12/17.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "AudioPlayControl.h"

@interface AudioPlayControl ()
@property (nonatomic, strong) UIImageView   *playView;
@property (nonatomic, strong) UIImageView   *bgView;
@end

@implementation AudioPlayControl

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_bgView.layer setCornerRadius:4.0];
        [_bgView.layer setBorderColor:[UIColor colorWithHex:0x666666].CGColor];
        [_bgView.layer setBorderWidth:kLineHeight1px];
        [self addSubview:_bgView];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timeLabel setBackgroundColor:[UIColor whiteColor]];
        [_timeLabel setUserInteractionEnabled:NO];
        [_timeLabel setTextColor:[UIColor colorWithHex:0x666666]];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_timeLabel];
        
        
        self.playView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_playView setTag:2012];
        [_playView setImage:[UIImage imageNamed:@"audio4"]];
        
        NSArray *animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"audio1"],
                                    [UIImage imageNamed:@"audio2"],
                                    [UIImage imageNamed:@"audio3"], nil];
        [_playView setAnimationImages:animationImages];
        _playView.animationDuration = 20/30.0;
        [self addSubview:_playView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopPlayAnimation)
                                                     name:NotificationsStopPlayAudio
                                                   object:nil];
    }
    
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [_bgView setFrame:CGRectMake(0, (self.frame.size.height - 28)/2.0, self.frame.size.width, 28)];
    [_timeLabel setFrame:CGRectMake(10, (self.frame.size.height - 20)/2.0, 40, 20)];
    [_playView setFrame:CGRectMake(self.frame.size.width - 30, (self.frame.size.height - 19)/2.0, 17, 19)];
}

- (void)startPlayAnimation {
    [_playView startAnimating];
}


- (void)stopPlayAnimation {
    [_playView stopAnimating];
}

// =====================================================================
#pragma mark Touch Tracking
// ======================================================================

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    [self setBackgroundColor:[UIColor whiteColor]];
    return YES;
}



- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    [self setBackgroundColor:[UIColor whiteColor]];
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}


- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    [self setBackgroundColor:[UIColor whiteColor]];
}

// 交互统计
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [super sendAction:action to:target forEvent:event];
}


@end
