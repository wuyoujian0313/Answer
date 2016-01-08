//
//  QuestionBaseVC.m
//  Answer
//
//  Created by wuyj on 16/1/8.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "QuestionBaseVC.h"



@interface QuestionBaseVC ()<AVAudioPlayerDelegate>
@end

@implementation QuestionBaseVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlay)
                                                 name:NotificationsStopPlayAudio
                                               object:nil];
}

- (void)stopPlay {
    [_audioPlayer stop];
}

- (void)playVideo {
    
    if (_videoURL != nil) {
        self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:_videoURL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer.moviePlayer];
        [_moviePlayer.moviePlayer setControlStyle: MPMovieControlStyleFullscreen];
        [_moviePlayer.moviePlayer play];
        
        [self presentMoviePlayerViewControllerAnimated:_moviePlayer];
        
    }
}

- (void)movieFinishedCallback:(NSNotification *)notify {
    
    MPMoviePlayerController *vc = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:vc];
    
    _moviePlayer = nil;
}

- (void)playReordFile {
    
    [_audioPlayer stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
    // 播放
    
    NSError *playerError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfURL:_audioURL] error:&playerError];
    if (_audioPlayer) {
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
#endif
    
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_audioPlayer stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_audioPlayer stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
}

@end
