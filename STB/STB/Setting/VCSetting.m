//
//  VCSetting.m
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "VCSetting.h"
#import "FactoryReset.h"
#import "PasswordAlert.h"
#import "LockInfo.h"
#import "SearchChannelTool.h"
#import "VersionUpdate.h"
#import "ConfirmUtil.h"

@interface VCSetting ()

@property (strong, nonatomic) IBOutlet UIButton *btnTitle;
//自动退出timer
@property (strong,nonatomic) NSTimer *outSetTimer;
@property (strong,nonatomic) UIAlertView *exitAlert;
@property (strong,nonatomic) NSTimer *exitAlertTimer;
@property (nonatomic) NSInteger alertTimeout;

@end

@implementation VCSetting

- (void)autoExitTimerAction
{
    if (self.alertTimeout>0) {
        self.alertTimeout--;
        if (self.alertTimeout==0) {
            [self.exitAlertTimer invalidate];
            self.exitAlertTimer = nil;
            [self.exitAlert dismissWithClickedButtonIndex:self.exitAlert.firstOtherButtonIndex animated:YES];
        }
        else
        {
            NSString *msg = [NSString stringWithFormat:@"%@ %d",MyLocalizedString(@"Box Setup will exit"),self.alertTimeout];
            self.exitAlert.message = msg;
        }
    }    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.cancelButtonIndex) {
        [self configAutoExitTimer];
    }
    else
    {
        [self click_barBack:nil];
    }
    
    //倒计时关闭
    if (self.exitAlertTimer) {
        if (self.exitAlertTimer.isValid) {
            [self.exitAlertTimer invalidate];
        }
        self.exitAlertTimer = nil;
    }
    self.exitAlert = nil;
}

- (void)autoExit
{
    
    self.alertTimeout = 10;
    
    NSString *msg = [NSString stringWithFormat:@"%@ %d",MyLocalizedString(@"Box Setup will exit"),self.alertTimeout];
    self.exitAlert = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert") message:msg delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:MyLocalizedString(@"OK"), nil];
    [self.exitAlert show];
    
    self.exitAlertTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(autoExitTimerAction) userInfo:nil repeats:YES];
    
    
}

- (void)configAutoExitTimer
{
    if (self.outSetTimer) {
        if (self.outSetTimer.isValid) {
            [self.outSetTimer invalidate];
        }
    }
    self.outSetTimer = [NSTimer scheduledTimerWithTimeInterval:5*60 target:self selector:@selector(autoExit) userInfo:nil repeats:NO];
}

- (void)dealloc
{
    if (self.outSetTimer.isValid) {
        [self.outSetTimer invalidate];
    }
    self.outSetTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self configLanguage];
    
    [self configAutoExitTimer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(configAutoExitTimer)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired=1;
    [self.navigationController.view addGestureRecognizer:tapGesture];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disconnectedSTB:) name:DisconnectedSTBNotification object:nil];
}

//断开机顶盒时的消息处理
- (void)disconnectedSTB:(NSNotification*)obj
{
    [self click_barBack:nil];
}

//语言设置
- (void)configLanguage
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *txtTitle = (UILabel*)subView;
            txtTitle.text = MyLocalizedString(txtTitle.text);
        }
    }
    [self.btnTitle setTitle:MyLocalizedString(@"Box Setup") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation NS_DEPRECATED_IOS(2_0, 6_0)
{
    BOOL ret = NO;
    
    ret = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)|(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);

    return ret;
}

//返回上一界面
- (IBAction)click_barBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (self.outSetTimer.isValid) {
        [self.outSetTimer invalidate];
    }
    self.outSetTimer = nil;
}

//设置wifi
- (IBAction)click_btnWifi:(id)sender {
    [self configAutoExitTimer];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
    UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"WIFISetting"];
    [self.navigationController pushViewController:wifiSetting animated:YES];
    
}
- (IBAction)click_btnParentLock:(id)sender {
    
    [[PasswordAlert shareInstance] alertPassword:nil withMessage:MyLocalizedString(@"Please enter the menu password") withValidPasswordCallback:^BOOL(PasswordAlert *aAlert,NSString *password) {
        BOOL success = NO;
        if (![NSString isEmpty:[LockInfo shareInstance].passwd]
            && ([[LockInfo shareInstance].passwd isEqualToString:password]
                || [[LockInfo shareInstance].passwd_channel isEqualToString:password]
                || [[LockInfo shareInstance].univeral_passwd isEqualToString:password]
                ))
        {
            success = YES;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
            UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"ParentLock"];
            [self.navigationController pushViewController:wifiSetting animated:YES];
        }
        return success;
        
    }];
    
}

- (IBAction)click_btnMenuPassword:(id)sender {
    [self configAutoExitTimer];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
    UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"MenuPassword"];
    [self.navigationController pushViewController:wifiSetting animated:YES];
    
}

#pragma mark --------------------搜索节目
- (IBAction)click_btnSearchChannel:(id)sender {
    [self configAutoExitTimer];
    
    static ConfirmUtil *confirm = nil;
    if (confirm==nil) {
        confirm = [ConfirmUtil Util];
    }
    [confirm showConfirmWithTitle:MyLocalizedString(@"Alert") withMessage:MyLocalizedString(@"Confirm to search channel") WithOKBlcok:^{
        SearchChannelTool *searchTool = [SearchChannelTool shareInstance];
        [searchTool searchChannel];
    }withCancelBlock:^{
        
    }];

//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
//    UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"ChannelSearchView"];
//    [self.navigationController pushViewController:wifiSetting animated:YES];
    
}
- (IBAction)click_Version:(id)sender
{
    [self configAutoExitTimer];
    
    [[VersionUpdate shareInstance] uploadFile];
}

//恢复出厂设置
- (IBAction)click_btnFactoryReset:(id)sender {
    [self configAutoExitTimer];
    [[FactoryReset shareInstance] factoryReset];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self configAutoExitTimer];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


 

@end
