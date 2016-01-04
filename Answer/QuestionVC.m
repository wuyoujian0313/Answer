//
//  QuestionVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDImageCache.h"
#import "AppDelegate.h"
#import "PublishQuestionVC.h"
#import "FileCache.h"



typedef NS_ENUM(NSInteger,RecordStatus) {
    RecordStatus_none,
    RecordStatus_recording,
    RecordStatus_stop,
    RecordStatus_playing,
};


@interface QuestionVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property(nonatomic,copy)NSString                       *videoScanImageKey;
@property(nonatomic,copy)NSString                       *photoKey;
@property(nonatomic,copy)NSString                       *mp4KeyString;
@property(nonatomic,copy)NSString                       *recordFileKey;
@property(nonatomic,strong)AVAudioRecorder              *audioRecoder;
@property(nonatomic,strong)AVAudioPlayer                *audioPlayer;
@property(nonatomic,strong)NSTimer                      *timer;
@property(nonatomic,strong)UIImageView                  *recordAnimateView;
@property(nonatomic,strong)UILabel                      *recordText;
@property(nonatomic,strong)UIButton                     *recordBtn;
@property(nonatomic,strong)UIButton                     *cancelBtn;
@property(nonatomic,strong)UIButton                     *okBtn;
@property(nonatomic,assign)RecordStatus                 status;
@property(nonatomic,assign)NSInteger                    audioDurationSeconds;
@end

@implementation QuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    _status = RecordStatus_none;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutFuncView];
}

- (BOOL)canRecord {
    
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    
    return bCanRecord;
}

-(void)playReordFile {
    
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
    // 播放
    NSError *playerError;
    NSString* filePath = [[FileCache sharedFileCache] diskCachePathForKey:_recordFileKey];
    filePath = [filePath stringByAppendingPathExtension:@"m4a"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&playerError];
    if (_audioPlayer) {
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
#endif
}

- (void)recordAudioFile {
    // 录音
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    if (IsIOS8) {
        AVAudioSessionRecordPermission permission = [session recordPermission];
        if (permission == AVAudioSessionRecordPermissionDenied) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"麦克风被禁用" message:@"请在iPhone的“设置-隐私-麦克风”中允许访问麦克风" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
    } else if (![self canRecord]) {
        return;
    }
    
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    [session setActive:YES error:nil];
    
    //
    self.recordFileKey = [NSString stringWithFormat:@"%@",[NSString UUID]];
    NSString *filePath = [[FileCache sharedFileCache] diskCachePathForKey:_recordFileKey];
    filePath = [filePath stringByAppendingPathExtension:@"m4a"];
    [[FileCache sharedFileCache] removeFileForPath:filePath];
    
#if TARGET_IPHONE_SIMULATOR
#elif TARGET_OS_IPHONE
    
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    NSError *error;
    [self.audioRecoder stop];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.audioRecoder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:recordSetting error:&error];
    if (_audioRecoder) {
        [_audioRecoder prepareToRecord];
        [_audioRecoder record];
        //开启音量检测
        _audioRecoder.meteringEnabled = YES;
        _audioRecoder.delegate = self;
        
        //设置定时检测
        _timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    } else {
        [session setActive:NO error:nil];
        NSLog(@"%@", error.description);
    }
#endif
}

- (void)detectionVoice {
    [_audioRecoder updateMeters];//刷新音量数据
    
    double cTime = _audioRecoder.currentTime;
    if (cTime >= 60) {
        
        [_audioRecoder stop];
        [_timer invalidate];
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:_audioRecoder.url options:nil]; //
        CMTime audioDuration = audioAsset.duration;
        _audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
        return;
    }
    
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    double lowPassResults = pow(10, (0.03 * [_audioRecoder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    
    
    if (0<lowPassResults<=0.06) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder0"]];
    } else if (0.06<lowPassResults<=0.13) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder1"]];
    } else if (0.13<lowPassResults<=0.20) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder2"]];
    } else if (0.20<lowPassResults<=0.27) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder2"]];
    } else if (0.27<lowPassResults<=0.34) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder3"]];
    } else if (0.34<lowPassResults<=0.41) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder4"]];
        
    } else if (0.55<lowPassResults<=0.62) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder5"]];
    }else if (0.48<lowPassResults<=0.55) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder5"]];
        
    } else if (0.69<lowPassResults<=0.76) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder6"]];
    }else if (0.76<lowPassResults<=0.83) {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder7"]];
        
    } else if (0.83<lowPassResults<=1.0)  {
        
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder8"]];
    } else {
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder0"]];
    }
    
    
}

- (void)recordAction:(UIButton*)sender {
    if (_status == RecordStatus_none) {
        [sender setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        _status = RecordStatus_recording;
        [_recordAnimateView setHidden:NO];
        [_recordAnimateView setImage:[UIImage imageNamed:@"recorder0"]];
        [_recordText setHidden:YES];
        
        [self recordAudioFile];
        
        [UIView animateWithDuration:0.6 animations:^{
            //
            [self.tabBarController.tabBar setFrame:CGRectMake(0, screenHeight, screenWidth, 49)];
        }];

        
    } else if (_status == RecordStatus_recording) {
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_recordAnimateView setHidden:YES];
        [_recordText setHidden:NO];
        [_recordText setText:@"点击播放"];
        _status = RecordStatus_stop;
        _cancelBtn.enabled = YES;
        _okBtn.enabled = YES;

        [_audioRecoder stop];
        [_timer invalidate];
        
        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:_audioRecoder.url options:nil]; //
        CMTime audioDuration = audioAsset.duration;
        _audioDurationSeconds = CMTimeGetSeconds(audioDuration);
        
    } else if (_status == RecordStatus_stop) {
        [sender setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        _status = RecordStatus_playing;
        [_recordText setHidden:NO];
        [_recordText setText:@"播放中…"];
        
        //
        [self playReordFile];
        
    } else if (_status == RecordStatus_playing) {
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        _status = RecordStatus_stop;
        [_recordText setHidden:NO];
        [_recordText setText:@"点击播放"];
        [_audioPlayer stop];
    }
}

- (void)recoverRecorderViewStatus {
    _cancelBtn.enabled = NO;
    _okBtn.enabled = NO;
    _status = RecordStatus_none;
    [_recordAnimateView setHidden:YES];
    [_recordText setHidden:NO];
    [_recordBtn setImage:[UIImage imageNamed:@"recorder"] forState:UIControlStateNormal];
    [_recordText setText:@"点击录音"];
    [_audioPlayer stop];
    [_audioRecoder stop];
    [_timer invalidate];
    
    //
    [UIView animateWithDuration:0.6 animations:^{
        //
        [self.tabBarController.tabBar setFrame:CGRectMake(0, screenHeight-49, screenWidth, 49)];
    }];

}

- (void)sendRecordAction:(UIButton *)sender {
    if (sender.tag == 200) {
        // 取消
        NSString *filePath = [[FileCache sharedFileCache] diskCachePathForKey:_recordFileKey];
        filePath = [filePath stringByAppendingPathExtension:@"m4a"];
        [[FileCache sharedFileCache] removeFileForPath:filePath];
        
    } else if (sender.tag == 201) {
        // 确定
        PublishQuestionVC *vc = [[PublishQuestionVC alloc] init];
        vc.publishType = PublishType_audio;
        vc.recordFileKey = _recordFileKey;
        vc.recordDur = _audioDurationSeconds;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [self recoverRecorderViewStatus];
}

- (void)questionAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (tag == 100) {
        // 语音
        
    } else if (tag == 101) {
        // 选择照片
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        picker.delegate = self;
        picker.navigationBar.barTintColor = [UIColor whiteColor];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor blackColor],NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
        picker.navigationBar.titleTextAttributes = dict;
        [self presentViewController:picker animated:YES completion:^{
        }];
        
    } else if (tag == 102 || tag == 103) {
        // 拍照
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied ) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在iPhone的“设置-隐私-相机”中允许访问相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]) {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            if (tag == 102) {
                
                picker.allowsEditing = YES;
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            } else if (tag == 103) {
                
                picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];//kUTTypeImage
                picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                picker.videoMaximumDuration = 8.0;
                picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            }
            
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [UIColor blackColor],NSForegroundColorAttributeName,
                                  [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
            picker.navigationBar.titleTextAttributes = dict;
            picker.navigationBar.barTintColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:^{
            }];
        }
    }
    
    [self recoverRecorderViewStatus];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {} else {}
}

-(void)toMp4:(NSURL *)url {
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([presets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];

        self.mp4KeyString = [NSString stringWithFormat:@"%@",[NSString UUID]];
        NSString *mp4PathString = [[FileCache sharedFileCache] diskCachePathForKey:_mp4KeyString];
        mp4PathString = [mp4PathString stringByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = [NSURL fileURLWithPath:mp4PathString];
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:    
                case AVAssetExportSessionStatusCancelled: {
                    [FadePromptView showPromptStatus:@"视频转码失败" duration:1.0 positionY:screenHeight- 300 finishBlock:^{
                        //
                    }];
                    break;
                }
                case AVAssetExportSessionStatusCompleted: {
                    //
                    PublishQuestionVC *vc = [[PublishQuestionVC alloc] init];
                    vc.publishType = PublishType_video;
                    vc.videoKeyString = _mp4KeyString;
                    vc.imageKey = _videoScanImageKey;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
        }];
    }
}


-(void)getVideoScanImage:(NSURL *)url {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 1.0);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    self.videoScanImageKey = [NSString stringWithFormat:@"%@",[NSString UUID]];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache storeImage:img forKey:_videoScanImageKey];
    
    [self toMp4:url];
}


- (UIButton *)createButton:(UIImage*)image target:(id)target selector:(SEL)selector frame:(CGRect)frame {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:frame];
    [button setImageEdgeInsets:UIEdgeInsetsMake((frame.size.height - 25)/2.0, (frame.size.width - 25)/2.0, (frame.size.height - 25)/2.0, (frame.size.width - 25)/2.0)];
    
    return button;
}

- (void)layoutFuncView {
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 120, screenWidth - 20, 260)];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    [bgView.layer setBorderColor:[UIColor colorWithHex:0xcccccc].CGColor];
    [bgView.layer setBorderWidth:kLineHeight1px];
    [bgView.layer setCornerRadius:4.0];
    [bgView setClipsToBounds:YES];
    [self.view addSubview:bgView];
    
    
    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 20, 40)];
    [panelView setBackgroundColor:[UIColor colorWithHex:0x606060]];
    [panelView.layer setBorderColor:[UIColor colorWithHex:0x606060].CGColor];
    [panelView.layer setBorderWidth:kLineHeight1px];
    [bgView addSubview:panelView];
    
    CGFloat buttonWidth = (screenWidth - 20)/3.0;
    CGFloat left = 0;
    
    //    UIButton *audioButton = [self createButton:[UIImage imageNamed:@"audio"] target:self selector:@selector(questionAction:) frame:CGRectMake(left, 0, buttonWidth, 40)];
    //    audioButton.tag = 100;
    //    [panelView addSubview:audioButton];
    //    left += buttonWidth;
    
    
    UIButton *photoButton = [self createButton:[UIImage imageNamed:@"photo"] target:self selector:@selector(questionAction:) frame:CGRectMake(left,0, buttonWidth, 40)];
    photoButton.tag = 101;
    [panelView addSubview:photoButton];
    left += buttonWidth;
    
    UIButton *cameraButton = [self createButton:[UIImage imageNamed:@"camer"] target:self selector:@selector(questionAction:) frame:CGRectMake(left,0, buttonWidth, 40)];
    cameraButton.tag = 102;
    [panelView addSubview:cameraButton];
    left += buttonWidth;
    
    UIButton *videoButton = [self createButton:[UIImage imageNamed:@"videotape"] target:self selector:@selector(questionAction:) frame:CGRectMake(left,0, buttonWidth, 40)];
    videoButton.tag = 103;
    [panelView addSubview:videoButton];
    

    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recordBtn = recordBtn;
    [recordBtn setFrame:CGRectMake((panelView.frame.size.width - 220)/2.0, 60, 220, 160)];
    [recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn setImage:[UIImage imageNamed:@"recorder"] forState:UIControlStateNormal];
    [bgView addSubview:recordBtn];
    
    self.recordAnimateView = [[UIImageView alloc] initWithFrame:CGRectMake((bgView.frame.size.width - 60)/2.0, 60, 60, 60)];
    _recordAnimateView.hidden = YES;
    [bgView addSubview:_recordAnimateView];
    
    self.recordText = [[UILabel alloc] initWithFrame:CGRectMake((bgView.frame.size.width - 60)/2.0, 60, 60, 60)];
    [_recordText setText:@"点击录音"];
    [_recordText setFont:[UIFont systemFontOfSize:14]];
    [_recordText setBackgroundColor:[UIColor clearColor]];
    [_recordText setTextColor:[UIColor grayColor]];
    [bgView addSubview:_recordText];

    UIView *recordSendView = [[UIView alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height - 40, bgView.frame.size.width, 40)];
    [recordSendView setBackgroundColor:[UIColor clearColor]];
    [recordSendView setClipsToBounds:YES];
    [bgView addSubview:recordSendView];
    
    LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 0, recordSendView.frame.size.width, kLineHeight1px)];
    [recordSendView addSubview:line1];
    
    LineView *line2 = [[LineView alloc] initWithFrame:CGRectMake(recordSendView.frame.size.width/2.0, 0, kLineHeight1px, recordSendView.frame.size.height)];
    [recordSendView addSubview:line2];
    
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn = cancelBtn;
    [cancelBtn setFrame:CGRectMake(0, 0, recordSendView.frame.size.width/2.0, 44)];
    [cancelBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithHex:0xcccccc] forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:[UIColor colorWithHex:0xcccccc] forState:UIControlStateDisabled];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setEnabled:NO];
    [cancelBtn addTarget:self action:@selector(sendRecordAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTag:200];
    [recordSendView addSubview:cancelBtn];
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okBtn = okBtn;
    [okBtn setFrame:CGRectMake(recordSendView.frame.size.width/2.0,0, recordSendView.frame.size.width/2.0, 44)];
    [okBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor colorWithHex:0xcccccc] forState:UIControlStateHighlighted];
    [okBtn setTitleColor:[UIColor colorWithHex:0xcccccc] forState:UIControlStateDisabled];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    [okBtn setEnabled:NO];
    [okBtn addTarget:self action:@selector(sendRecordAction:) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTag:201];
    [recordSendView addSubview:okBtn];
}

#pragma mark - imagepicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        //
        __weak QuestionVC *weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
            UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
            CGSize scaleSize = [[UIScreen mainScreen] bounds].size;
            UIImage *imageScale = [image resizedImageByMagick:[NSString stringWithFormat:@"%ldx%ld",(long)scaleSize.width,(long)scaleSize.height]];
            
            self.photoKey = [NSString stringWithFormat:@"%@",[NSString UUID]];
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache storeImage:imageScale forKey:_photoKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [picker dismissViewControllerAnimated:YES completion:^{
                    //
                    PublishQuestionVC *vc = [[PublishQuestionVC alloc] init];
                    vc.publishType = PublishType_image;
                    vc.imageKey = _photoKey;
                    vc.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }];
            });
        });

    } else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        __weak QuestionVC *weakSelf = self;
        
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
                
                CGSize scaleSize = [[UIScreen mainScreen] bounds].size;
                UIImage *imageScale = [image resizedImageByMagick:[NSString stringWithFormat:@"%ldx%ld",(long)scaleSize.width,(long)scaleSize.height]];
            
                self.photoKey = [NSString stringWithFormat:@"%@",[NSString UUID]];
                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                [imageCache storeImage:imageScale forKey:_photoKey];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [picker dismissViewControllerAnimated:YES completion:^{
                        //
                        PublishQuestionVC *vc = [[PublishQuestionVC alloc] init];
                        vc.publishType = PublishType_image;
                        vc.imageKey = _photoKey;
                        vc.hidesBottomBarWhenPushed = YES;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                        
                    }];
                });
            });
        } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            //保存视频到相册
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:nil];
            
            [self getVideoScanImage:url];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                //
            }];
        }
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    [_recordBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    _status = RecordStatus_stop;
    [_recordText setHidden:NO];
    [_recordText setText:@"点击播放"];
    
    [_audioPlayer stop];
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_recordBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    _status = RecordStatus_stop;
    [_recordText setHidden:NO];
    [_recordText setText:@"点击播放"];
    [_audioPlayer stop];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    //    [recorder stop];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [recorder stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
