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

@interface VCSetting ()

@property (strong, nonatomic) IBOutlet UIButton *btnTitle;

@end

@implementation VCSetting

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self configLanguage];
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
    [self.btnTitle setTitle:MyLocalizedString(@"SETUP") forState:UIControlStateNormal];
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
}

//设置wifi
- (IBAction)click_btnWifi:(id)sender {
    
    [[PasswordAlert shareInstance] alertPassword:nil withMessage:MyLocalizedString(@"Please enter the menu password") withValidPasswordCallback:^BOOL(PasswordAlert *aAlert,NSString *password) {
        BOOL success = NO;
        if (![NSString isEmpty:[LockInfo shareInstance].passwd]
            &&
            ([[LockInfo shareInstance].passwd isEqualToString:password]
             || [[LockInfo shareInstance].univeral_passwd isEqualToString:password]
             ))
        {
            success = YES;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
            UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"WIFISetting"];
            [self.navigationController pushViewController:wifiSetting animated:YES];
        }
        
        return success;
        
    }];
    
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
    
    [[PasswordAlert shareInstance] alertPassword:nil withMessage:MyLocalizedString(@"Please enter the menu password") withValidPasswordCallback:^BOOL(PasswordAlert *aAlert,NSString *password) {
        BOOL success = NO;
        if (![NSString isEmpty:[LockInfo shareInstance].passwd]
            && ([[LockInfo shareInstance].passwd isEqualToString:password]
                || [[LockInfo shareInstance].univeral_passwd isEqualToString:password])
            )
        {
            success = YES;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
            UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"MenuPassword"];
            [self.navigationController pushViewController:wifiSetting animated:YES];
        }
        
        return success;
        
    }];
    
}

//
- (IBAction)click_btnSearchChannel:(id)sender {
    
    [[PasswordAlert shareInstance] alertPassword:nil withMessage:MyLocalizedString(@"Please enter the menu password") withValidPasswordCallback:^BOOL(PasswordAlert *aAlert,NSString *password) {
        BOOL success = NO;
        if (![NSString isEmpty:[LockInfo shareInstance].passwd]
            && ([[LockInfo shareInstance].passwd isEqualToString:password]
                || [[LockInfo shareInstance].univeral_passwd isEqualToString:password]
                ))
        {
            success = YES;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Video" bundle:nil];
            UIViewController *wifiSetting = [storyboard instantiateViewControllerWithIdentifier:@"ChannelSearchView"];
            [self.navigationController pushViewController:wifiSetting animated:YES];            
        }
        
        return success;
        
    }];
    
}
- (IBAction)click_Version:(id)sender
{
    [[VersionUpdate shareInstance] uploadFile];
}

//恢复出厂设置
- (IBAction)click_btnFactoryReset:(id)sender {
    [[FactoryReset shareInstance] factoryReset];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


 

@end
