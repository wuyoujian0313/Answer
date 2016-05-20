//
//  PublishQuestionVC.m
//  Answer
//
//  Created by wuyj on 15/12/2.
//  Copyright © 2015年 wuyj. All rights reserved.
//

#import "PublishQuestionVC.h"
#import "RedPacketVC.h"
#import "MyFriendsVC.h"
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
#import "BaiduMapLocationResult.h"



#define MaxWordNumber           300

@interface PublishQuestionVC ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,NetworkTaskDelegate,CLLocationManagerDelegate,RedSetDelegate,SelectedFriendIdsDelegate>

@property (nonatomic, strong) UITableView                  *publishTableView;
@property (nonatomic, strong) AudioPlayControl             *audioControl;
@property (nonatomic, strong) UITapGestureRecognizer       *tapGesture;
@property (nonatomic, strong) SZTextView                   *contentTextView;
@property (nonatomic, strong) UILabel                      *remainNumLabel;
@property (nonatomic, strong) UIButton                     *publishBtn;
@property (nonatomic, copy) NSString                       *commentString;
@property (nonatomic, strong) CLLocationManager            *locmanager;
@property (nonatomic, strong) NSNumber                     *latitude;
@property (nonatomic, strong) NSNumber                     *longitude;
@property (nonatomic, strong) UIButton                     *locBtn;
@property (nonatomic, copy) NSString                       *locString;
@property (nonatomic, copy) NSString                       *friendIdsString;
@property (nonatomic, strong) UIButton                     *redBtn;
@property (nonatomic, strong) UIButton                     *atBtn;

@property (nonatomic, assign) BOOL                         isAnonymous;
@property (nonatomic, assign) NSInteger                    reward;
@property (nonatomic, strong) NSTimer                      *timer;
@property (nonatomic, assign) BOOL                         firstLocation;
@property (nonatomic, strong) BaiduMapLocationResult       *locationResult;

@end

@implementation PublishQuestionVC

- (void)dealloc {
    [_tapGesture.view removeGestureRecognizer:_tapGesture];
    [_timer invalidate];
    [_locmanager stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"发布问题"];
    [self layoutPublishTableView];
    __weak PublishQuestionVC *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf beginGPS];
    });
    
    _isAnonymous = YES;
    _firstLocation = YES;
    
    //设置定时检测，5分钟调用一次接口
    self.timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(refreshLocation) userInfo:nil repeats:YES];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoAction:)];
    self.tapGesture = tap;
}

-(void)popBack {
    [_timer invalidate];
    [super popBack];
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
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"注意" message:@"您的定位服务并未打开，请到设置面板中打开图问的定位服务功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)layoutPublishTableView {
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationBarHeight, self.view.frame.size.width, self.view.frame.size.height-navigationBarHeight) style:UITableViewStylePlain];
    [self setPublishTableView:tableView];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor whiteColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
}

-(void)playReordFile:(AudioPlayControl*)sender {
    
    NSString* filePath = [[FileCache sharedFileCache] diskCachePathForKey:_recordFileKey];
    filePath = [filePath stringByAppendingPathExtension:@"m4a"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self playReordFile:fileURL];
}

- (void)playVideo:(UIButton*)sender {

    NSString *videoPath = [[FileCache sharedFileCache] diskCachePathForKey:_videoKeyString];
    videoPath = [videoPath stringByAppendingPathExtension:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:videoPath];
    [self playVideo:fileURL];
}

- (void)tapPhotoAction:(UITapGestureRecognizer *)sender {
    UIImageView *senderImageView = (UIImageView*)sender.view;
    
    XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
    [imageViewer showWithImageViews:[NSArray arrayWithObject:senderImageView] selectedView:senderImageView];
}


- (void)publishQuestion {

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:[User sharedUser].user.uId forKey:@"userId"];
    if ([_locBtn titleForState:UIControlStateNormal]) {
        [param setObject:[_locBtn titleForState:UIControlStateNormal] forKey:@"address"];
    }
    
    if ([_longitude stringValue]) {
        [param setObject:[_longitude stringValue] forKey:@"longitude"];
    }
    
    if ([_latitude stringValue]) {
        [param setObject:[_latitude stringValue] forKey:@"latitude"];
    }
    
    
    
    [param setObject:@"生活" forKey:@"fenlei"];
    
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_reward] forKey:@"reward"];
    if (_isAnonymous) {
        [param setObject:@"1" forKey:@"isAnonymous"];
    } else {
        [param setObject:@"0" forKey:@"isAnonymous"];
    }
    
    if (_commentString && [_commentString length]) {
        [param setObject:_commentString forKey:@"content"];
    } else {
        [param setObject:@"" forKey:@"content"];
    }
    
    [param setObject:[NSString stringWithFormat:@"%ld",(long)_recordDur] forKey:@"mediaLen"];
    
    if (_friendIdsString) {
        [param setObject:_friendIdsString forKey:@"atFriends"];
    }
    
    NetResultBase *result = nil;
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

- (void)refreshLocation {
    
    NSLog(@"latitude %@, longitude %@", [_latitude stringValue], [_longitude stringValue]);
    NSMutableString *locURLString = [[NSMutableString alloc] init];
    [locURLString appendString:BaiduGeocoderURL];
    [locURLString appendFormat:@"ak=%@",BaiduMapLocationAK];
    [locURLString appendFormat:@"&location=%@,%@",[_latitude stringValue],[_longitude stringValue]];
    
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    [locURLString appendFormat:@"&mcode=%@",bundleId];
    [locURLString appendString:@"&output=json&pois=0&coordtype=wgs84ll"];

    [[NetworkTask sharedNetworkTask] startGETTaskURL:locURLString
                                            delegate:self
                                           resultObj:[[BaiduMapLocationResult alloc] init]
                                          customInfo:@"location"];
}

- (void)toolAction:(UIButton*)sender {
    if (sender.tag == 300) {
        // 定位
        [self refreshLocation];
    } else if (sender.tag == 301) {
        
        // 匿名设置
        _isAnonymous = !_isAnonymous;
        UIImage *image = [UIImage imageNamed:@"unanonymous"];
        if (_isAnonymous) {
            image = [UIImage imageNamed:@"anonymous"];
        }
        
        [sender setImage:image forState:UIControlStateNormal];
        
        
    } else if (sender.tag == 302) {
        // 好友设置
        MyFriendsVC *vc = [[MyFriendsVC alloc] init];
        vc.enterType = EnterType_FromPublishQuestion;
        vc.delegate = self;
        vc.selectedIdsString = _friendIdsString;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 303) {
        // 红包设置
        RedPacketVC *vc = [[RedPacketVC alloc] init];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - RedSetDelegate
-(void)setRedNumber:(NSInteger)number {
    _reward = number;
    [_redBtn setTitle:[NSString stringWithFormat:@"%ld",(long)_reward] forState:UIControlStateNormal];
}

#pragma mark - SelectedFriendIdsDelegate
// 用,拼接
-(void)setSelectedFriendIds:(NSString*)idsString number:(NSInteger)number {
    self.friendIdsString = idsString;

    [_atBtn setTitle:[NSString stringWithFormat:@"%ld",(long)number] forState:UIControlStateNormal];
}


#pragma mark - NetworkTaskDelegate
-(void)netResultSuccessBack:(NetResultBase *)result forInfo:(id)customInfo {
    [SVProgressHUD dismiss];
    if ([customInfo isEqualToString:@"publishQuestion"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationAddNewQuestion object:nil];
        
        if (_publishType == PublishType_audio) {
            
            NSString *filePath = [[FileCache sharedFileCache] diskCachePathForKey:_recordFileKey];
            filePath = [filePath stringByAppendingPathExtension:@"m4a"];
            [[FileCache sharedFileCache] removeFileForPath:filePath];
        } else if (_publishType == PublishType_video) {
            
            NSString *filePath = [[FileCache sharedFileCache] diskCachePathForKey:_videoKeyString];
            filePath = [filePath stringByAppendingPathExtension:@"mp4"];
            [[FileCache sharedFileCache] removeFileForPath:filePath];
            
            [[SDImageCache sharedImageCache] removeImageForKey:_imageKey];
        } else {
            [[SDImageCache sharedImageCache] removeImageForKey:_imageKey];
        }
        
        [FadePromptView showPromptStatus:@"发布成功" duration:1.0 finishBlock:^{
            //
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else if ([customInfo isEqualToString:@"location"]) {
        BaiduMapLocationResult *locRec = (BaiduMapLocationResult*)result;
        if ([locRec poiRegions] && [[locRec poiRegions] count]) {
            BaiduMapPOIRegions *poi = [[locRec poiRegions] objectAtIndex:0];
            
            NSString *poiName = poi.name;
           // NSString *city = locRec.addressComponent.city;
            
            [_locBtn setTitle:poiName forState:UIControlStateNormal];
        } else if(locRec.formatted_address && [locRec.formatted_address length]) {
            [_locBtn setTitle:locRec.formatted_address forState:UIControlStateNormal];
        }
        
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

    self.latitude = [NSNumber numberWithDouble:userLatitude];
    self.longitude = [NSNumber numberWithDouble:userLongitude];
    
    if (_firstLocation) {
        [self refreshLocation];
        _firstLocation = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [_locmanager stopUpdatingLocation];
                break;
            case kCLErrorLocationUnknown:
                [_locmanager stopUpdatingLocation];
                break;
            default:
                break;
        }
    }
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
            [audioControl addTarget:self action:@selector(playReordFile:) forControlEvents:UIControlEventTouchUpInside];
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
            [playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
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
        
            [audioControl.timeLabel setText:[NSString stringWithFormat:@"%ld\"",(long)_recordDur]];
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
            
            self.remainNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, tableView.frame.size.width - 20, 15)];
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
        
            
            LineView *line1 = [[LineView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line1];
            
            //
            CGFloat left = 10;
            CGFloat top = 0;
            CGFloat btnWidth = 50;
            UIButton *locBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.locBtn = locBtn;
            [locBtn setTag:300];
            [locBtn setFrame:CGRectMake(left, top, tableView.frame.size.width -  3*btnWidth - 10, 44)];
            [locBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [locBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
            [locBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [locBtn setTitle:_locString forState:UIControlStateNormal];
            [locBtn addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:locBtn];
            
            left = tableView.frame.size.width -  btnWidth;
            UIButton *redBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.redBtn = redBtn;
            [redBtn setTag:303];
            [redBtn setFrame:CGRectMake(left, 2, btnWidth, 40)];
            [redBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [redBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
            [redBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [redBtn addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImage *image = [UIImage imageNamed:@"redPacketNum"];
            [redBtn setImage:image forState:UIControlStateNormal];
            [redBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [redBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, -image.size.width/2.0 - 16, 0, 0)];
            [redBtn setTitle:@"0" forState:UIControlStateNormal];
            [cell.contentView addSubview:redBtn];
            
            
            left -= btnWidth;
            UIButton *atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.atBtn = atBtn;
            [atBtn setTag:302];
            [atBtn setFrame:CGRectMake(left, 4, btnWidth, 40)];
            [atBtn setImage:[UIImage imageNamed:@"atFriend"] forState:UIControlStateNormal];
            [atBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [atBtn setTitle:@"0" forState:UIControlStateNormal];
            [atBtn setTitleColor:[UIColor colorWithHex:0x56b5f5] forState:UIControlStateNormal];
            [atBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width/2.0 - 16, 0, 0)];
            [atBtn addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:atBtn];
            
            left -= btnWidth;
            UIButton *pubilcBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [pubilcBtn setTag:301];
            [pubilcBtn setFrame:CGRectMake(left, 2, btnWidth, 40)];
            [pubilcBtn addTarget:self action:@selector(toolAction:) forControlEvents:UIControlEventTouchUpInside];
            if (_isAnonymous) {
                [pubilcBtn setImage:[UIImage imageNamed:@"anonymous"] forState:UIControlStateNormal];
            } else {
                [pubilcBtn setImage:[UIImage imageNamed:@"unanonymous"] forState:UIControlStateNormal];
            }
            
            [cell.contentView addSubview:pubilcBtn];
            
            LineView *line2 = [[LineView alloc] initWithFrame:CGRectMake(0, 44 - kLineHeight1px, tableView.frame.size.width, kLineHeight1px)];
            [cell.contentView addSubview:line2];
        }
        
        //
        
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
        return 120;
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
    _remainNumLabel.text = [NSString stringWithFormat:@"剩余%lu",(long)(MaxWordNumber - [textView.text length])];
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
