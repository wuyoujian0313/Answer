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
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "FileCache.h"
#import "AudioPlayControl.h"
#import "NetworkTask.h"
#import "XHImageViewer.h"
#import "SDImageCache.h"
#import "SZTextView.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "User.h"
#import "CommitPictureResult.h"
#import "CommitVideoResult.h"
#import "CommitVoiceResult.h"

#define MaxWordNumber           300

@interface PublishQuestionVC ()<AVAudioPlayerDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,NetworkTaskDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) UITableView                  *publishTableView;
@property (nonatomic, strong) AudioPlayControl             *audioControl;
@property (nonatomic, strong) MPMoviePlayerViewController  *moviePlayer;
@property (nonatomic, strong) AVAudioPlayer                *audioPlayer;
@property (nonatomic, strong) UITapGestureRecognizer       *tapGesture;
@property (nonatomic, strong) SZTextView                   *contentTextView;
@property (nonatomic, strong) UILabel                      *remainNumLabel;
@property (nonatomic, strong) UIButton                     *publishBtn;
@property (nonatomic, copy) NSString                       *commentString;
@property (nonatomic, strong) CLLocationManager            *locmanager;
@property (nonatomic, strong) NSNumber                     *latitude;
@property (nonatomic, strong) NSNumber                     *longitude;
@end

@implementation PublishQuestionVC

- (void)dealloc {
    [_tapGesture.view removeGestureRecognizer:_tapGesture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"发布问题"];
    [self layoutPublishTableView];
    [self beginGPS];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    self.tapGesture = tap;
}

- (void)beginGPS {
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        
        self.locmanager = [[CLLocationManager alloc] init];
        [_locmanager setDelegate:self];
        [_locmanager setDesiredAccuracy:kCLLocationAccuracyBest];
        if ([_locmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locmanager requestWhenInUseAuthorization];
        }
        if ([_locmanager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locmanager requestAlwaysAuthorization];
        }
        
        [_locmanager startUpdatingLocation];
    } else {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"注意" message:@"您的定位服务并未打开，请到设置面板中打开百度移动办公定位服务功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)layoutPublishTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height-navigationBarHeight) style:UITableViewStylePlain];
    [self setPublishTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
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

- (void)playVideo {

    NSString *videoPath = [[FileCache sharedFileCache] diskCachePathForKey:_videoKeyString];
    videoPath = [videoPath stringByAppendingPathExtension:@"mp4"];
    if (videoPath != nil && [videoPath length] > 0) {
        self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoPath]];
        
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

- (void)tapPhotoAction:(UITapGestureRecognizer *)sender {
    UIImageView *senderImageView = (UIImageView*)sender.view;
    
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    [imageViewer showWithImageViews:[NSArray arrayWithObject:senderImageView] selectedView:senderImageView];
}


- (void)publishQuestion {

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    [param setObject:@"北京 海淀" forKey:@"address"];
    [param setObject:@"1" forKey:@"longitude"];
    [param setObject:@"1" forKey:@"latitude"];
    [param setObject:@"生活" forKey:@"fenlei"];
    [param setObject:@"6" forKey:@"reward"];
    [param setObject:@"0" forKey:@"isAnonymous"];
    
    [param setObject:_contentTextView.text forKey:@"content"];
    
    
    
    NetResultBase *result = [[CommitPictureResult alloc] init];
    NSMutableArray *uploadFiles = [[NSMutableArray alloc] init];
    
    if (_publishType == PublishType_audio) {
        
        [param setObject:@"0" forKey:@"wtype"];
        result = [[CommitVoiceResult alloc] init];
        
        NSString* filePath = [[FileCache sharedFileCache] diskCachePathForKey:_recordFileKey];
        filePath = [filePath stringByAppendingPathExtension:@"m4a"];
        NSData  *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        NSString *mimeType = @"voice/m4a";
        
        NSString *key1 = [NSString UUID];
        UploadFileInfo *info1 = [[UploadFileInfo alloc] init];
        info1.fileName = [key1 stringByAppendingPathExtension:@"m4a"];
        info1.mimeType = mimeType;
        info1.fileData = imageData;
        info1.key = @"fileName";
        
        [uploadFiles addObject:info1];
        
        NSString *key2 = [NSString UUID];
        UploadFileInfo *info2 = [[UploadFileInfo alloc] init];
        info2.fileName = [key2 stringByAppendingPathExtension:@"png"];
        info2.mimeType = @"image/png";
        
        UIImage *image = [UIImage imageFromColor:[UIColor blackColor]];
        NSData *thumbnailData = UIImagePNGRepresentation(image);
        info2.fileData = thumbnailData;
        info2.key = @"thumbnail";
        
        [uploadFiles addObject:info2];
        
    } else if(_publishType == PublishType_image) {
        [param setObject:@"2" forKey:@"wtype"];
        result = [[CommitPictureResult alloc] init];
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        UIImage *image = [imageCache imageFromDiskCacheForKey:_imageKey];
        NSData *imageData = UIImagePNGRepresentation(image);
        NSString *mimeType = @"image/png";
        
        NSString *key1 = [NSString UUID];
        UploadFileInfo *info1 = [[UploadFileInfo alloc] init];
        info1.fileName = [key1 stringByAppendingPathExtension:@"png"];
        info1.mimeType = mimeType;
        info1.fileData = imageData;
        info1.key = @"fileName";
        
        [uploadFiles addObject:info1];
        
        NSString *key2 = [NSString UUID];
        UploadFileInfo *info2 = [[UploadFileInfo alloc] init];
        info2.fileName = [key2 stringByAppendingPathExtension:@"png"];
        info2.mimeType = @"image/png";
        
        UIImage *thumbnail = [UIImage imageFromColor:[UIColor blackColor]];
        NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
        info2.fileData = thumbnailData;
        info2.key = @"thumbnail";
        
        [uploadFiles addObject:info2];
        
    } else if (_publishType == PublishType_video) {
        
        [param setObject:@"1" forKey:@"wtype"];
        result = [[CommitVideoResult alloc] init];
        
        NSString* filePath = [[FileCache sharedFileCache] diskCachePathForKey:_videoKeyString];
        filePath = [filePath stringByAppendingPathExtension:@"mp4"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        NSString *mimeType = @"video/mp4";
        
        NSString *key1 = [NSString UUID];
        UploadFileInfo *info1 = [[UploadFileInfo alloc] init];
        info1.fileName = [key1 stringByAppendingPathExtension:@"mp4"];
        info1.mimeType = mimeType;
        info1.fileData = imageData;
        info1.key = @"fileName";
        
        [uploadFiles addObject:info1];
        
        NSString *key2 = [NSString UUID];
        UploadFileInfo *info2 = [[UploadFileInfo alloc] init];
        info2.fileName = [key2 stringByAppendingPathExtension:@"png"];
        info2.mimeType = @"image/png";
        
        
        SDImageCache *imageCache = [SDImageCache sharedImageCache];
        UIImage *thumbnail = [imageCache imageFromDiskCacheForKey:_imageKey];
        NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
        info2.fileData = thumbnailData;
        info2.key = @"thumbnail";
        
        [uploadFiles addObject:info2];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[NetworkTask sharedNetworkTask] startUploadTaskApi:API_AddTuWen
                                               forParam:param
                                                  files:uploadFiles
                                               delegate:self
                                              resultObj:result
                                             customInfo:@"publishQuestion"];
    
}

- (void)sendAction:(UIButton*)sender {
    [self publishQuestion];
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"publishQuestion"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationChangeUserHeadImage object:nil];
        
        [FadePromptView showPromptStatus:@"发布成功" duration:1.0 finishBlock:^{
            //
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}


-(void)netResultFailBack:(NSString *)errorDesc errorCode:(NSInteger)errorCode forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    [FadePromptView showPromptStatus:errorDesc duration:1.0 finishBlock:^{
        //
    }];
}


#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    double userLatitude = newLocation.coordinate.latitude;
    double userLongitude = newLocation.coordinate.longitude;
    NSLog(@"latitude %f, longitude %f", userLatitude, userLongitude);
    
    self.latitude = [NSNumber numberWithDouble:userLatitude];
    self.longitude = [NSNumber numberWithDouble:userLatitude];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [_locmanager stopUpdatingLocation];
                break;
            case kCLErrorLocationUnknown:
                break;
            default:
                break;
        }
    }
}



#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_audioControl stopPlayAnimation];
    [_audioPlayer stop];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_audioControl stopPlayAnimation];
    [_audioPlayer stop];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 不使用重用机制
    NSInteger row = [indexPath row];
    NSInteger curRow = 0;
    
    if (row == curRow) {
        static NSString *reusedCellID = @"publish1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            AudioPlayControl *audioControl = [[AudioPlayControl alloc] initWithFrame:CGRectZero];
            [audioControl setTag:100];
            self.audioControl = audioControl;
            [audioControl setHidden:YES];
            [audioControl addTarget:self action:@selector(playReordFile) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:audioControl];
            
            UIImageView *contentImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            [contentImage setContentMode:UIViewContentModeScaleAspectFill];
            [contentImage setClipsToBounds:YES];
            [contentImage setUserInteractionEnabled:YES];
            [contentImage setHidden:YES];
            [contentImage setTag:101];
            [cell.contentView addSubview:contentImage];
            
            UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [playBtn setTag:102];
            [playBtn setHidden:YES];
            [playBtn setImageEdgeInsets:UIEdgeInsetsMake(30, 30, 30, 30)];
            [playBtn setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
            [playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:playBtn];
        }
        
        //
        AudioPlayControl *audioControl = (AudioPlayControl *)[cell.contentView viewWithTag:100];
        UIImageView *contentImage = (UIImageView *)[cell.contentView viewWithTag:101];
        UIButton *playBtn = (UIButton*)[cell.contentView viewWithTag:102];
        
        audioControl.hidden = YES;
        contentImage.hidden = YES;
        playBtn.hidden = YES;
        if ([contentImage.gestureRecognizers containsObject:_tapGesture]) {
            [contentImage removeGestureRecognizer:_tapGesture];
        }
        
        if (_publishType == PublishType_audio) {
            audioControl.hidden = NO;
        
            [audioControl.timeLabel setText:[NSString stringWithFormat:@"%d\"",_recordDur]];
            [audioControl setFrame:CGRectMake(10, 10, tableView.frame.size.width - 20, 55)];
        } else if (_publishType == PublishType_image || _publishType == PublishType_video) {
            [contentImage addGestureRecognizer:_tapGesture];
            [contentImage setFrame:CGRectMake((tableView.frame.size.width - 200)/2.0, 10, 200, 120)];
            contentImage.hidden = NO;
            
            playBtn.hidden = !(_publishType == PublishType_video);
            [playBtn setFrame:CGRectMake((tableView.frame.size.width - 120)/2.0, 10, 120, 120)];
            
            //取图片缓存
            SDImageCache* imageCache = [SDImageCache sharedImageCache];
            //从缓存取
            UIImage * cacheimage = [imageCache imageFromDiskCacheForKey:_imageKey];
            contentImage.image = cacheimage;
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"publish2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            
            self.contentTextView = [[SZTextView alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 100)];
            _contentTextView.delegate = self;
            _contentTextView.clipsToBounds = YES;
            _contentTextView.backgroundColor = [UIColor clearColor];
            _contentTextView.keyboardType = UIKeyboardTypeDefault;
            _contentTextView.returnKeyType = UIReturnKeyDefault;
            _contentTextView.placeholder = @"请输入你的文字描述";
            _contentTextView.font = [UIFont systemFontOfSize:14];
            _contentTextView.textColor = [UIColor colorWithHex:0x666666];
            _contentTextView.placeholderTextColor = [UIColor colorWithHex:0xcccccc];
            [cell.contentView addSubview:_contentTextView];
            
            self.remainNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, tableView.frame.size.width - 11, 15)];
            _remainNumLabel.backgroundColor = [UIColor clearColor];
            _remainNumLabel.textAlignment = NSTextAlignmentRight;
            _remainNumLabel.text = [NSString stringWithFormat:@"剩余%d",MaxWordNumber];
            _remainNumLabel.textColor = [UIColor colorWithHex:0xcccccc];
            _remainNumLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:_remainNumLabel];
            
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"publish3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
            [v setBackgroundColor:[UIColor colorWithHex:0xcccccc]];
            [cell.contentView addSubview:v];
        }
        
        return cell;
    }
    
    curRow ++;
    if (row == curRow) {
        static NSString *reusedCellID = @"publish4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedCellID];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self setPublishBtn:publishBtn];
            [publishBtn setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithHex:0x56b5f5]] forState:UIControlStateNormal];
            [publishBtn.layer setCornerRadius:5.0];
            [publishBtn setClipsToBounds:YES];
            [publishBtn setTitle:@"发布" forState:UIControlStateNormal];
            [publishBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
            [publishBtn setFrame:CGRectMake(10, 60, tableView.frame.size.width - 20, 40)];
            [publishBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:publishBtn];
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (_publishType == PublishType_audio) {
            return 75;
        } else{
            return 140;
        }
    } else if (indexPath.row == 1) {
        return 115;
    } else if (indexPath.row == 2) {
        return 44;
    } else if (indexPath.row == 3) {
        return 110;
    }
    
    return 0;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSMutableString *textString = [NSMutableString stringWithString:textView.text];
    [textString replaceCharactersInRange:range withString:text];
    
    if ([textString length] > MaxWordNumber) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSString *temp = [NSString stringWithFormat:@"%@",textView.text];
    if ([temp length] > MaxWordNumber) {
        
        textView.text = _commentString;
        return;
    }
    
    self.commentString = temp;
    _remainNumLabel.text = [NSString stringWithFormat:@"剩余%d",MaxWordNumber - [textView.text length]];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_contentTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
