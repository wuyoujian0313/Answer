//
//  QuestionBaseVC.m
//  Answer
//
//  Created by wuyj on 16/1/8.
//  Copyright © 2016年 wuyj. All rights reserved.
//

#import "QuestionBaseVC.h"
#import "FileCache.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>

@interface QuestionBaseVC ()<AVAudioPlayerDelegate>
@end

@implementation QuestionBaseVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationsStopPlayAudio object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlay)
                                                 name:NotificationsStopPlayAudio
                                               object:nil];
}

- (void)shareMenu {
    
    
    //    // 授权
    //    [ShareSDK authorize:SSDKPlatformTypeWechat settings:@{SSDKAuthSettingKeyScopes : @[@"snsapi_userinfo"]} onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
    //        //
    //    }];
    //
    //
    //    return;
    
    //1、创建分享参数
    NSString *url = kSharedURL;
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:@"我正在使用“图问”，快来围观吧！"
                                     images:[UIImage imageNamed:@"180"]
                                        url:[NSURL URLWithString:url]
                                      title:@"图问分享"
                                       type:SSDKContentTypeAuto];
    
    //2、分享（可以弹出我们的分享菜单和编辑界面）
    [ShareSDK showShareActionSheet:self.view
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   
                   switch (state) {
                       case SSDKResponseStateBegin: {
                           
                           break;
                       }
                           
                           
                       case SSDKResponseStateSuccess: {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                           
                       case SSDKResponseStateFail: {
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                           message:[NSString stringWithFormat:@"%@",error]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil, nil];
                           [alert show];
                           break;
                       }
                           
                       case SSDKResponseStateCancel: {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       default:
                           break;
                   }
               }
     ];
}

- (void)stopPlay {
    [_audioPlayer stop];
}

- (void)playVideo {

    __weak QuestionBaseVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        QuestionBaseVC *sself = weakSelf;
        
        if (sself.videoURL != nil) {
            
            FileCache *sharedCache = [FileCache sharedFileCache];
            NSString *cachePath = [sharedCache diskCachePathForKey:[sself.videoURL absoluteString]];
            cachePath = [cachePath stringByAppendingPathExtension:@"mp4"];
            
            NSData *data = [sharedCache dataFromCacheForPath:cachePath];
            if (data == nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *ndata = [NSData dataWithContentsOfURL:sself.videoURL];
                    [sharedCache writeData:ndata path:cachePath];
                });
                
                
                sself.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoURL];
                
                [[NSNotificationCenter defaultCenter] addObserver:sself selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:sself.moviePlayer.moviePlayer];
                [sself.moviePlayer.moviePlayer setControlStyle: MPMovieControlStyleFullscreen];
                [sself.moviePlayer.moviePlayer play];
                
                [sself presentMoviePlayerViewControllerAnimated:sself.moviePlayer];
            } else {
                sself.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:cachePath]];
                
                [[NSNotificationCenter defaultCenter] addObserver:sself selector:@selector(movieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:sself.moviePlayer.moviePlayer];
                [sself.moviePlayer.moviePlayer setControlStyle: MPMovieControlStyleFullscreen];
                [sself.moviePlayer.moviePlayer play];
                
                [sself presentMoviePlayerViewControllerAnimated:sself.moviePlayer];
            }
        }
    });
}

- (void)movieFinishedCallback:(NSNotification *)notify {
    
    MPMoviePlayerController *vc = [notify object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:vc];
    
    _moviePlayer = nil;
}

- (void)playReordFile {
    
    [_audioPlayer stop];
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
    // 播放
    
    __weak QuestionBaseVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *playerError;
        
        QuestionBaseVC *sself = weakSelf;
        
        FileCache *sharedCache = [FileCache sharedFileCache];
        NSData *data = [sharedCache dataFromCacheForKey:[sself.audioURL absoluteString]];
        if (data == nil) {
            
            data = [NSData dataWithContentsOfURL:sself.audioURL];
            [sharedCache writeData:data forKey:[sself.audioURL absoluteString]];
        }
        
        sself.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
        if (sself.audioPlayer) {
            sself.audioPlayer.delegate = self;
            [sself.audioPlayer prepareToPlay];
            [sself.audioPlayer play];
            
        } else {
            NSLog(@"ERror creating player: %@", [playerError description]);
        }
        
        
    });
    
    
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
