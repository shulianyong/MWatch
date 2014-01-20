//
//  VideoController.m
//  STB
//
//  Created by shulianyong on 13-10-11.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "VideoController.h"
#import "KxAudioManager.h"

#import <MediaPlayer/MPMusicPlayerController.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "MovieViewer.h"
#import "VCManager.h"
#import "STBPlayer.h"
#import "CommonUtil.h"
#import "LockInfo.h"
#import "VersionUpdate.h"

//音轨管理
#import "AudioTrackManager.h"

#import "../../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"

#import "MovieViewDelegate.h"

//网络处理
#import "AFNetworking.h"
#import "CommandClient.h"
#import "STBMonitor.h"

#import "PasswordAlert.h"
#import "SingleAlert.h"
#import "InputAlert.h"
#import "YDSlider.h"

#import "ConfirmMunePassword.h"

#import "VerifySTBConnected.h"
#import "DefaultChannelTool.h"

@interface VideoController ()<MovieViewDelegate,VideoControllerDelegate,VerifySTBConnectedDelegate>
{
    CGFloat volumeValue;
    BOOL searchedChannel;//现在状态是，已经经过搜索，但是没有播放
    BOOL isAppearView;//是否在本界面
}

@property (strong, nonatomic) IBOutlet UIView *tbarBottom;
@property (strong, nonatomic) IBOutlet UIView *vMovie;
@property (strong, nonatomic) IBOutlet VCManager *tblChannel;
@property (strong, nonatomic) IBOutlet UIButton *btnRefresh;
@property (strong, nonatomic) IBOutlet UIView *leftSeparator;

@property (nonatomic) CGRect movieViewerFrame;

@property (nonatomic,strong)STBPlayer *player;
@property (nonatomic,strong)STBPlayer *nextPlayer;

//全屏处理
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singleTap;
@property (nonatomic) BOOL isFullScreen;

//手动输入的播放地址
@property (strong,nonatomic) NSString *inputPath;

//音量选择器
@property (strong, nonatomic) IBOutlet UISlider *sldVolume;
@property (strong, nonatomic) IBOutlet YDSlider *csldVolume;

@property (strong, nonatomic) IBOutlet UIButton *btnVolume;

//音频控制器
@property (nonatomic,strong)MPMusicPlayerController *volumeController;

//播放timer
@property (nonatomic,strong) NSTimer *playTimer;

#warning 测试代码
@property (nonatomic,strong) NSString *tempPlayAddress;
@property (nonatomic) float minBuffer;
@property (nonatomic) float maxBuffer;
@property (nonatomic) int analyzeTime;


@end

@implementation VideoController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.volumeController = [[MPMusicPlayerController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    self.tblChannel.videoDelegate = self;
    self.tblChannel.tableHeaderView = self.btnRefresh;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNotifycation:) name:PlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseNotifycation:) name:PauseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotifiycation:) name:RefreshChannelListNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllChannelNotification:) name:DeleteAllChannelListNotification object:nil];
    
    //设置网络变化时的回调
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChannelNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    //声音控制
    volumeValue = self.volumeController.volume;
    self.sldVolume.value = volumeValue;
    [self configSlideVolume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.player didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL ret = NO;
    
    ret = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)|(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    return ret;
}

- (void)viewDidAppear:(BOOL)animated
{
    isAppearView = YES;
    [super viewDidAppear:animated];
    self.movieViewerFrame = self.vMovie.frame;
    self.player.frame = self.vMovie.bounds;
    //设置不让系统变黑屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (searchedChannel&&self.tblChannel.fetchedResultsController.fetchedObjects.count>0) {
        [self playChannel:self.tblChannel.selectedChannel];
    }
    else
    {
        if (self.tblChannel.fetchedResultsController.fetchedObjects.count>0) {
            [self.player play];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isAppearView = NO;
    //设置不让系统变黑屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.player pause];
}

#pragma mark ------------------------ 联接机顶盒成功，失败的处理方式
- (void)ConnectedSTBSuccess
{
    [SingleAlert shareInstance].alertView = nil;
    __weak VideoController *weakSelf = self;
    
    //刷新列表
    [weakSelf.tblChannel refreshChannel];
    
    //注册事件
    INFO(@"注册事件");
    [[STBMonitor shareInstance] eventMonitor];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        dispatch_async(dispatch_get_main_queue(), ^{
            //获取密码，主机密码等等...
            [CommandClient commandGetLockControl:^(id info, HTTPAccessState isSuccess) {
                
            }];
        });
    });
}

- (void)ConnectedSTBFail
{
    [SingleAlert showMessage:MyLocalizedString(@"TV box not found，please check!")];
    [self.player pause];
    if ([VersionUpdate IsSTBRemindUpgrade])
    {
        //更新更新机顶盒固件
        [[VersionUpdate shareInstance] updateVersionWithAuto:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DisconnectedSTBNotification object:nil];
}

#pragma mark----------------------- 网络变化处理
- (void)refreshChannelNotification:(NSNotification*)obj
{
    NSDictionary *networkDic = [obj userInfo];
    AFNetworkReachabilityStatus status = [[networkDic objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if (status==AFNetworkReachabilityStatusReachableViaWiFi) {
        [VerifySTBConnected verifyConnectedWithBackDelegate:self];
    }
    else
    {
        [self ConnectedSTBFail];
    }
}
- (IBAction)click_BtnrefreshChannel:(id)sender {
    __weak UIButton *btnSender = sender;
    [self.tblChannel refreshChannel];
    btnSender.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //让刷新按钮不可用，3秒之后可用
        sleep(3);
        dispatch_sync(dispatch_get_main_queue(), ^{
            btnSender.enabled = YES;
        });
    });
}


#pragma mark ---------------------------
#pragma mark --------------------------- 切换频道

#pragma mark -----------------------播放消息
- (void)playNotifycation:(NSNotification*)obj
{
    if (isAppearView && self.player) {
        [self.player play];
    }
}

- (void)pauseNotifycation:(NSNotification*)obj
{
    [self.player pause];
}

- (void)refreshNotifiycation:(NSNotification*)obj
{
    [self.tblChannel refreshChannel];
    searchedChannel = YES;
}

- (void)deleteAllChannelNotification:(NSNotification*)obj
{
    [self.player stopVideo];
    [self.tblChannel deleteAllChannel];
}

#pragma mark -----------------------切换切目的代理
- (void)playChannel:(Channel*)aChannel
{
    if (isAppearView) {
        [[DefaultChannelTool shareInstance] configDefaultChannel:aChannel];
        [self switchChannel:[self currentPlayPath]];
        searchedChannel = NO;
    }
}

- (void)stopChannel
{
    if (self.player) {
        [self.player stopVideo];
    }
}

//是否在有效期内
- (BOOL)timeValid
{
    //设置有效期
	NSDateFormatter *formatter = [self dateFormatter];
    NSString *validString =@"2014-02-18";
    NSDate *validDate = [formatter dateFromString:validString];
    
    NSDate *nowtime = [NSDate date];
    if (nowtime.timeIntervalSince1970>validDate.timeIntervalSince1970) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert")
                                                        message:MyLocalizedString(@"Version is expired")
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
    return (nowtime.timeIntervalSince1970<validDate.timeIntervalSince1970);
}

#pragma mark ----播放地址

- (NSString*)currentPlayPath
{
    NSInteger currentChannel = [DefaultChannelTool shareInstance].defaultChannelId;
    if (currentChannel==0) {
        nil;
    }
    NSString *path = [STBInfo shareInstance].stbPlayURL;
    path = [NSString stringWithFormat:@"%@%d",path,currentChannel];
    if ([STBInfo shareInstance].connected==false) {
        path = nil;
    }
#warning 测试代码
    if (![NSString isEmpty:self.tempPlayAddress]) {
        path = self.tempPlayAddress;
    }
    
    NSLog(@"path:%@",path);
    return path;
}

#pragma mark ------- timer,一个半小时候，重新播放
- (void)setPlayTimer:(NSTimer *)playTimer
{
    if (_playTimer) {
        [_playTimer invalidate];
    }
    _playTimer = playTimer;
}

- (void)timeout:(NSTimer*)sender
{
    _playTimer = nil;
    if (isAppearView) {
        [self switchChannel:[self currentPlayPath]];
    }
    else
    {
        searchedChannel = YES;
    }
}

#pragma mark ---- 正式切换播放
- (void)switchChannel:(NSString*)path
{
    //播放方法
    dispatch_block_t playBlock = ^{
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[ParameterDisableDeinterlacing] = @(YES);
        if ([path.pathExtension isEqualToString:@"wmv"])
            parameters[ParameterMinBufferedDuration] = @(5.0);
        
        
        STBPlayer *player = [[STBPlayer alloc] init];
        [player configScreenFrame:self.vMovie.bounds];
        [player setBackgroundColor:[UIColor blackColor]];
        
        //设置缓存
        parameters[ParameterMaxBufferedDuration] = @(30.0);//最大缓存
        parameters[ParameterMinBufferedDuration] = @(1.0);//最小缓存
        //设置最大分析时间
        player.maxAnalyzeDuration = 4;
        
#warning 测试代码
        if (self.minBuffer>0) {
            parameters[ParameterMinBufferedDuration] = @(self.minBuffer);//最小缓存
        }
        if (self.maxBuffer>0) {
            parameters[ParameterMaxBufferedDuration] = @(self.maxBuffer);
        }
        if (self.analyzeTime>0) {
            player.maxAnalyzeDuration = self.analyzeTime;
        }
        
        //播放
        [self setPlayer:player];
        
        [self.player initWithContentPath:path parameters:parameters];
    };
    
    
    //设置让系统变黑屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if ([NSString isEmpty:path]) {
        return;
    }
    
#warning 测试代码
    playBlock();
    return;
//    
//    if (![self timeValid]) {
//        return;
//    }
    //设置播放时间，
//    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
//    if (self.player) {
//        [self.player stopVideo];
//    }
//    playBlock();
  
    
//    Channel *currentChannel = [self.tblChannel selectedChannel];
//    if (currentChannel.lock.boolValue) {
//        [[PasswordAlert shareInstance] alertPassword:nil withMessage:MyLocalizedString(@"Please enter the menu password") withValidPasswordCallback:^BOOL(PasswordAlert *aAlert, NSString *password) {
//            BOOL success = NO;
//            if (![NSString isEmpty:[LockInfo shareInstance].passwd]
//                &&![NSString isEmpty:[LockInfo shareInstance].passwd_channel]
//                && ([[LockInfo shareInstance].passwd isEqualToString:password]
//                    || [[LockInfo shareInstance].passwd_channel isEqualToString:password]
//                    || [[LockInfo shareInstance].univeral_passwd isEqualToString:password]
//                    )
//                )
//            {
//                success = YES;
//                playBlock();
//            }
//            return success;
//        }];
//    }
//    else
//    {
//        playBlock();
//    }
    
    
}

- (NSDateFormatter*)dateFormatter {
	static NSDateFormatter *formatter = nil;
	if (formatter == nil)  {
		formatter = [[NSDateFormatter alloc] init];
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:enUS];
		[formatter setDateFormat:@"yyyy-MM-dd"];
	}
	return formatter;
}

- (void)setPlayer:(STBPlayer *)player
{
    if (![self timeValid]) {
        return;
    }
    //播放
    player.movieDelegate = self;
    player.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleLeftMargin;
    [self.vMovie addSubview:player];
    
    if (_player) {
        [_player stopVideo];
        [_player removeFromSuperview];
    }
    
    _player = player;
}

#pragma mark --------------------- MovieViewDelegate
//播放失败，在播放失败时，调用该方法
- (void)fail:(_PlayerFailType)aFailType withPlay:(id<MovieViewProtocol>)aPlayer
{
    NSLog(@"fail");
    if (aFailType == PlayerReplayFail) {
        [self switchChannel:[self currentPlayPath]];
    }
    
}

//正在加载,在接收到播放请求后，从网络中获取 视频数据时，返回的百分比
- (void)loading:(NSString*)aPercent withPlay:(id<MovieViewProtocol>)aPlayer
{
    NSLog(@"loading");
}

//加载结束，并且播放时，回调
- (void)loadend:(id<MovieViewProtocol>)aPlayer
{
    NSLog(@"loadend");
    //设置不让系统变黑屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

#pragma mark ---------------------频道信息
- (IBAction)click_btnInfo:(id)sender {
    Channel *aChannel = nil;
    NSString *title = nil;
    NSString *message = nil;
    NSInteger count = self.tblChannel.fetchedResultsController.fetchedObjects.count;
    if (count==0) {
        title = MyLocalizedString(@"Alert");
        message = MyLocalizedString(@"NO Channel");
    }
    else
    {
        NSInteger index = 0;
        NSInteger currentChannel = [DefaultChannelTool shareInstance].defaultChannelId;
        for (NSInteger i=0;i<count;i++) {
            Channel *temp = self.tblChannel.fetchedResultsController.fetchedObjects[i];
            if (temp.channelId.integerValue == currentChannel) {
                aChannel = temp;
                index = i;
                break;
            }
        }
        if (aChannel) {
            title = aChannel.name;
            message = [NSString stringWithFormat:@"%@",aChannel];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:MyLocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark ---------------------全屏操作

- (IBAction)tapPlayer:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (sender==self.singleTap) {
            [UIViewController attemptRotationToDeviceOrientation];
            self.isFullScreen = !self.isFullScreen;
            
            [UIView beginAnimations:@"fullScreen" context:nil];
            if (self.isFullScreen) {
                CGRect fullFrame = self.view.bounds;
                self.vMovie.frame = fullFrame;
                [self.player configScreenFrame:self.vMovie.bounds];
                self.tblChannel.alpha = 0;
                self.tbarBottom.alpha = 0;
            }
            else
            {
                self.vMovie.frame = self.movieViewerFrame;
                
                CGRect tempFrame = self.movieViewerFrame;
                tempFrame.origin.x=0;
                tempFrame.origin.y=0;                
                [self.player configScreenFrame:tempFrame];
                self.tblChannel.alpha = 1;
                self.tbarBottom.alpha = 1;
            }
            [UIView commitAnimations];
        }
        else if (sender == self.doubleTap)
        {
            [self.player fullScreen];
        }
    }
}

#pragma mark -------------滑动控制
- (IBAction)directionControl:(UISwipeGestureRecognizer*)sender {
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            self.volumeController.volume +=0.1;
            self.csldVolume.value = self.volumeController.volume;
            volumeValue = self.volumeController.volume;
            self.btnVolume.selected = volumeValue==0;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            self.volumeController.volume -=0.1;
            self.csldVolume.value = self.volumeController.volume;
            volumeValue = self.volumeController.volume;
            self.btnVolume.selected = volumeValue==0;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self click_preChannel:nil];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [self click_nextChannel:nil];
            break;
        default:
            break;
    }
    
}


#pragma mark －－－－－－－－音轨处理
- (IBAction)click_AudioTrackItem:(id)sender
{
    AudioTrackManager *trackManager = [[AudioTrackManager alloc] initWithStyle:UITableViewStylePlain];
    trackManager.player = self.player;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:trackManager] animated:YES completion:^{
        [self.player pause];
    }];
//    [self.player audioTrack];
}

#pragma mark -------------------节目控制

- (IBAction)click_pause:(id)sender {
    [self.player pause];
}

- (IBAction)click_preChannel:(id)sender
{
    Channel *preChannel = [self.tblChannel preChannel];
    NSIndexPath *indexPath = [self.tblChannel.fetchedResultsController indexPathForObject:preChannel];
    [self.tblChannel selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    //设置当前正在播放的channelId;
    [[DefaultChannelTool shareInstance] configDefaultChannel:preChannel];
    [self switchChannel:[self currentPlayPath]];
}
- (IBAction)click_nextChannel:(id)sender
{
    Channel *nextChannel = [self.tblChannel nextChannel];
    NSIndexPath *indexPath = [self.tblChannel.fetchedResultsController indexPathForObject:nextChannel];
    
    //选中播放项
    [self.tblChannel selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    //设置当前正在播放的channelId
    [[DefaultChannelTool shareInstance] configDefaultChannel:nextChannel];
    [self switchChannel:[self currentPlayPath]];
}

#pragma mark --------------------
#pragma mark --------------------音量控制

- (IBAction)slideVolume:(UISlider *)sender {
    self.volumeController.volume = sender.value;
    volumeValue = sender.value;
    self.btnVolume.selected = volumeValue==0;
}
- (IBAction)cslideVolume:(YDSlider *)sender {
    self.volumeController.volume = sender.value;
    volumeValue = sender.value;
    self.btnVolume.selected = volumeValue==0;
}

- (void)configSlideVolume
{
    self.csldVolume.value = self.volumeController.volume;
    
    [self.csldVolume setThumbImage:[UIImage imageNamed:@"player-progress-point.png"] forState:UIControlStateNormal];
    [self.csldVolume setThumbImage:[UIImage imageNamed:@"player-progress-point-h.png"] forState:UIControlStateHighlighted];
    //设置slider最左边一段的颜色
    self.csldVolume.minimumTrackTintColor = [UIColor orangeColor];
    //设置slider最右边一段的颜色
    self.csldVolume.maximumTrackTintColor = RGBColor(57,60,86);
    
    [self cslideVolume:self.csldVolume];
}

#pragma mark 静音设置
- (IBAction)click_volume:(id)sender
{
    [self configMute];
}

- (void)configMute
{
    BOOL ismuted = self.btnVolume.selected;
    ismuted = !ismuted;
    
    self.btnVolume.selected = ismuted;
    if (ismuted) {
        self.volumeController.volume = 0.0f;
        self.csldVolume.value = 0.0f;
    }
    else
    {
        self.volumeController.volume = volumeValue;
        self.csldVolume.value = volumeValue;
    }
}

#pragma mark -------------------- 设置
- (IBAction)clickBtnSetting:(id)sender
{
    if (![STBInfo shareInstance].connected) {
       [SingleAlert showMessage:MyLocalizedString(@"Please connect TV Box")];
    }
    else
    {
        __weak VideoController *weakSelf = self;
        [[ConfirmMunePassword shareInstance] confirmMunePassword:^(BOOL aResult) {
            if (aResult) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
                UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"VCSetingController"];
                [weakSelf presentViewController:wifiSetting animated:YES completion:^{
                }];
            }
        }];
        
       
    }
}

#pragma mark --------------测试代码
- (IBAction)click_Minbuffer:(id)sender
{
    [InputAlert alertMessage:@"请输入MinBuffer" withResultBlock:^(NSString *aResult) {
        float result = [aResult floatValue];
        if (result>0) {
            self.minBuffer = result;
            [self switchChannel:[self currentPlayPath]];
        }
    }];
}
- (IBAction)click_MaxBuffer:(id)sender
{
    [InputAlert alertMessage:@"请输入MaxBuffer" withResultBlock:^(NSString *aResult) {
        float result = [aResult floatValue];
        if (result>0) {
            self.maxBuffer = result;
            [self switchChannel:[self currentPlayPath]];
        }
    }];
}
- (IBAction)click_AnalyzeTime:(id)sender
{
    [InputAlert alertMessage:@"请输入分析时间" withResultBlock:^(NSString *aResult) {
        int result = [aResult intValue];
        if (result>0) {
            self.analyzeTime = result;
            [self switchChannel:[self currentPlayPath]];
        }
    }];
}
- (IBAction)click_PlayAddress:(id)sender
{
    [InputAlert alertMessage:@"请输入播放地址" withResultBlock:^(NSString *aResult) {
        self.tempPlayAddress = aResult;
        [self switchChannel:[self currentPlayPath]];
    }];
}




@end
