//
//  PublishQuestionVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "PublishQuestionVC.h"
#import "RedPacketVC.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PublishQuestionVC ()

@property(nonatomic,copy)NSString                       *videoPathString;
@property(nonatomic,strong)MPMoviePlayerViewController  *moviePlayer;

@end

@implementation PublishQuestionVC

-(void)setVideoKeyString:(NSString *)videoKeyString {
    _videoKeyString = videoKeyString;
    
    NSString *mp4PathString = [NSString stringWithFormat:@"%@%@.mp4",NSTemporaryDirectory(),_videoKeyString];
    [self setVideoPathString:mp4PathString];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)playVideo:(UIButton*)sender {
    
    NSString  *src = _videoPathString;
    if (src != nil && [src length] > 0) {
        self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:src]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer.moviePlayer];
        [_moviePlayer.moviePlayer setControlStyle: MPMovieControlStyleFullscreen];
        [_moviePlayer.moviePlayer play];
        
        [self presentMoviePlayerViewControllerAnimated:_moviePlayer];
    }
}

-(void)movieFinishedCallback:(NSNotification *)notify {
    
    MPMoviePlayerController *vc = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:vc];
    
    _moviePlayer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
