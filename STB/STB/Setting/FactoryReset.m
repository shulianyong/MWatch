//
//  FactoryReset.m
//  STB
//
//  Created by shulianyong on 13-10-26.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "FactoryReset.h"
#import "CommandClient.h"
#import "LockInfo.h"
#import "CommonUtil.h"
#import "MBProgressHUD.h"

@interface FactoryReset ()<MBProgressHUDDelegate>

@property (nonatomic,strong) MBProgressHUD *updateAlert;

@end

@implementation FactoryReset

+ (FactoryReset*)shareInstance
{
    static FactoryReset *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FactoryReset alloc] init];
    });
    
    return instance;
}

- (void)factoryReset
{
    
    [self alertFactorReset];
}

- (void)alertPassword:(BOOL)isnotCorrect
{
    NSString *message = isnotCorrect?MyLocalizedString(@"The password is not correct,please reenter"):MyLocalizedString(@"Please enter the menu password");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:MyLocalizedString(@"Cancel")
                                              otherButtonTitles:MyLocalizedString(@"OK"), nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alertView.tag = 1;
    [alertView show];
}

- (void)alertFactorReset
{
    NSString *message = MyLocalizedString(@"Are you really want to run the factory reset?");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Warning")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:MyLocalizedString(@"Cancel")
                                              otherButtonTitles:MyLocalizedString(@"OK"), nil];
    alertView.tag = 2;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        if (alertView.tag==1)
        {
            UITextField *txtPassword = [alertView textFieldAtIndex:0];
            NSString *password = txtPassword.text;
            
            LockInfo *currentLockInfo = [LockInfo shareInstance];
            if (![NSString isEmpty:password] && ([password isEqualToString:currentLockInfo.passwd] || [password isEqualToString:currentLockInfo.univeral_passwd])) {
                [self alertFactorReset];
            }
            else//提示密码不正确
            {
                [self alertPassword:YES];
            }
        }//用户确定恢复出厂设置
        else
        {
            
            UIWindow *window = [[UIApplication sharedApplication].delegate window];
            self.updateAlert = [[MBProgressHUD alloc] initWithView:window];
            [window addSubview:self.updateAlert];
            self.updateAlert.delegate = self;
            self.updateAlert.labelText = MyLocalizedString(@"Loading...");
            [self.updateAlert show:YES];
            __weak FactoryReset *weakSelf = self;
            
            __block BOOL completeRequest = NO;
           
            [CommandClient commandFactoryReset:^(id info, HTTPAccessState isSuccess) {
                if (completeRequest) {
                    return;
                }
                
                completeRequest = YES;
                if (isSuccess==HTTPAccessStateSuccess) {
                    weakSelf.updateAlert.labelText= MyLocalizedString(@"Factory reset success");
                    //清空节目单
                    [[NSNotificationCenter defaultCenter] postNotificationName:DeleteAllChannelListNotification object:nil];
                    //请求更新节目单事件
//                    [CommandClient postRefreshChannelEvent];
                }
                else
                {
                    weakSelf.updateAlert.labelText=MyLocalizedString(@"Factory reset fail");
                }
                [weakSelf.updateAlert hide:YES afterDelay:2];
            }];
            //设置10秒钟的超时时间
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                sleep(12);
                if(!completeRequest)
                {
                    completeRequest = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        weakSelf.updateAlert.labelText=MyLocalizedString(@"Factory reset fail");
                        [weakSelf.updateAlert hide:YES afterDelay:2];
                    });
                }
                
            });
            
        }
    }
}

#pragma mark 提示框
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    self.updateAlert = nil;
}

@end
