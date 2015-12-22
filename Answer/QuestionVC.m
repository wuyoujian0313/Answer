//
//  QuestionVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "QuestionVC.h"
#import "RedPacketVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDImageCache.h"

@interface QuestionVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate>

@property(nonatomic,strong)UIImagePickerController      *picker;
@property(nonatomic,copy)NSString                       *videoScanImageKey;
@property(nonatomic,copy)NSString                       *photoKey;
@property(nonatomic,copy)NSString                       *videoUrlString;
@property(nonatomic,copy)NSString                       *mp4KeyString;

@end

@implementation QuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = nil;
    [self setNavTitle:self.tabBarItem.title];
    [self layoutFuncView];
}

- (UIButton *)createButton:(UIImage*)image target:(id)target selector:(SEL)selector frame:(CGRect)frame {
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:frame];
    [button setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

    return button;
}

- (void)layoutFuncView {
    
    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, screenWidth - 40, 60)];
    [panelView.layer setCornerRadius:4.0];
    [panelView setBackgroundColor:[UIColor colorWithHex:0xdddddd]];
    [self.view addSubview:panelView];
    
    CGFloat buttonWidth = (screenWidth - 40 - 8)/4.0;
    
    UIButton *audioButton = [self createButton:[UIImage imageNamed:@"tabbar_home"] target:self selector:@selector(questionAction:) frame:CGRectMake(0, 0, buttonWidth, 60)];
    audioButton.tag = 100;
    [panelView addSubview:audioButton];
    
    UIButton *phontoButton = [self createButton:[UIImage imageNamed:@"tabbar_circle"] target:self selector:@selector(questionAction:) frame:CGRectMake(buttonWidth,0, buttonWidth, 60)];
    phontoButton.tag = 101;
    [panelView addSubview:phontoButton];
    
    UIButton *cameraButton = [self createButton:[UIImage imageNamed:@"tabbar_message"] target:self selector:@selector(questionAction:) frame:CGRectMake(2*buttonWidth,0, buttonWidth, 60)];
    cameraButton.tag = 102;
    [panelView addSubview:cameraButton];
    
    UIButton *videoButton = [self createButton:[UIImage imageNamed:@"tabbar_question"] target:self selector:@selector(questionAction:) frame:CGRectMake(3*buttonWidth,0, buttonWidth, 60)];
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
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
