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


@interface QuestionVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property(nonatomic,strong)UIImagePickerController      *picker;
@property(nonatomic,copy)NSString                       *videoScanImageKey;
@property(nonatomic,copy)NSString                       *photoKey;
@property(nonatomic,copy)NSString                       *videoUrlString;
@property(nonatomic,copy)NSString                       *mp4KeyString;
@property(nonatomic,strong)NSURL                        *recordedFile;
@property(nonatomic,copy)NSString                       *recordFileKey;
@property(nonatomic,strong)AVAudioRecorder              *audioRecoder;
@property(nonatomic,strong)AVAudioPlayer                *audioPlayer;
@property(nonatomic,strong)NSTimer                      *timer;

@end

@implementation QuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem * rightItem = [self configBarButtonWithTitle:@"取消" target:self selector:@selector(cancelSend)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutFuncView];
}

-(void)viewWillAppear:(BOOL)animated {

    [UIView animateWithDuration:0.6 animations:^{
        //
        [self.tabBarController.tabBar setFrame:CGRectMake(0, screenHeight, screenWidth, 49)];
    }];
}

- (void)cancelSend {

    AppDelegate *app = [AppDelegate shareMyApplication];
    [app.mainVC setShowHomeVC];
    
    [UIView animateWithDuration:0.6 animations:^{
        //
        [self.tabBarController.tabBar setFrame:CGRectMake(0, screenHeight - 49, screenWidth, 49)];
    }];
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
    
//#if TARGET_IPHONE_SIMULATOR
//#elif TARGET_OS_IPHONE
    // 播放
    NSError *playerError;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordedFile error:&playerError];
    if (_audioPlayer) {
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    } else {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
//#endif
    
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:_recordedFile error:nil];
    
//#if TARGET_IPHONE_SIMULATOR
//#elif TARGET_OS_IPHONE
    
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    NSError *error;
    [self.audioRecoder stop];
    self.audioRecoder = [[AVAudioRecorder alloc] initWithURL:_recordedFile settings:recordSetting error:&error];
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
//#endif
}

- (void)detectionVoice {
    [_audioRecoder updateMeters];//刷新音量数据
    
    double cTime = _audioRecoder.currentTime;
    if (cTime >= 60) {
        
        [_audioRecoder stop];
        [_timer invalidate];
        
        return;
    }
    
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    double lowPassResults = pow(10, (0.05 * [_audioRecoder peakPowerForChannel:0]));
    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if ( 0 < lowPassResults <= 0.06 ) {
    } else if (0.06<lowPassResults<=0.13) {
    } else if (0.13<lowPassResults<=0.20) {
    } else if (0.20<lowPassResults<=0.27) {
    } else if (0.27<lowPassResults<=0.34) {
    } else if (0.34<lowPassResults<=0.41) {
    } else if (0.55<lowPassResults<=0.62) {
    } else if (0.48<lowPassResults<=0.55) {
    } else if (0.69<lowPassResults<=0.76) {
    } else if (0.76<lowPassResults<=0.83) {
    } else if (0.83<lowPassResults<=0.9)  {
    } else {
    }
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
    
    UIImageView *panelView = [[UIImageView alloc] initWithFrame:CGRectMake(10, screenHeight - 60, screenWidth - 20, 40)];
    [panelView setImage:[UIImage imageNamed:@"tool-bg"]];
    [panelView setUserInteractionEnabled:YES];
    [self.view addSubview:panelView];
    
    CGFloat buttonWidth = (screenWidth - 20)/4.0;
    
    UIButton *audioButton = [self createButton:[UIImage imageNamed:@"audio"] target:self selector:@selector(questionAction:) frame:CGRectMake(0, 0, buttonWidth, 40)];
    audioButton.tag = 100;
    [panelView addSubview:audioButton];
    
    UIButton *photoButton = [self createButton:[UIImage imageNamed:@"photo"] target:self selector:@selector(questionAction:) frame:CGRectMake(buttonWidth,0, buttonWidth, 40)];
    photoButton.tag = 101;
    [panelView addSubview:photoButton];
    
    UIButton *cameraButton = [self createButton:[UIImage imageNamed:@"camer"] target:self selector:@selector(questionAction:) frame:CGRectMake(2*buttonWidth,0, buttonWidth, 40)];
    cameraButton.tag = 102;
    [panelView addSubview:cameraButton];
    
    UIButton *videoButton = [self createButton:[UIImage imageNamed:@"videotape"] target:self selector:@selector(questionAction:) frame:CGRectMake(3*buttonWidth,0, buttonWidth, 40)];
    videoButton.tag = 103;
    [panelView addSubview:videoButton];
}

- (void)questionAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (tag == 100) {
        // 语音
        
    } else if (tag == 101) {
        // 选择照片
        
        self.picker = [[UIImagePickerController alloc] init];
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _picker.allowsEditing = YES;
        _picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        _picker.delegate = self;
        _picker.navigationBar.barTintColor = [UIColor whiteColor];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIColor blackColor],NSForegroundColorAttributeName,
                              [UIFont systemFontOfSize:18],NSFontAttributeName,nil];
        _picker.navigationBar.titleTextAttributes = dict;
        [self presentViewController:_picker animated:YES completion:^{
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
            picker.navigationBar.barTintColor = [UIColor whiteColor];;
            
            self.picker = picker;
            [self presentViewController:picker animated:YES completion:^{
            }];
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != nil) {} else {}
}

-(void)saveImg:(UIImage *)image {
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    self.videoScanImageKey = [NSString stringWithFormat:@"%@",[NSString UUID]];
    [imageCache storeImage:image forKey:_videoScanImageKey];
    
    [self toMp4];
}

-(void)toMp4 {
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:_videoUrlString] options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        self.mp4KeyString = [NSString stringWithFormat:@"%@",[NSString UUID]];
        NSString *mp4PathString = [NSString stringWithFormat:@"%@%@.mp4",NSTemporaryDirectory(),_mp4KeyString];
        
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
                    break;
                }
                default:
                    break;
            }
        }];
    }
}


-(void)getPreViewImg:(NSURL *)url {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 1.0);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    [self performSelector:@selector(saveImg:) withObject:img afterDelay:0.1];
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
            [imageCache storeImage:imageScale forKey:_videoScanImageKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [picker dismissViewControllerAnimated:YES completion:^{
                    //
                    
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
                [imageCache storeImage:imageScale forKey:_videoScanImageKey];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [picker dismissViewControllerAnimated:YES completion:^{
                        //
                        
                    }];
                });
            });
        } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            self.videoUrlString = [NSString stringWithFormat:@"%@",[url absoluteString]];
            //保存视频到相册
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeVideoAtPathToSavedPhotosAlbum:url completionBlock:nil];
            
            [self getPreViewImg:url];
            
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
    [_audioPlayer stop];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
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
