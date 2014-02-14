//
//  ConfirmMunePassword.m
//  STB
//
//  Created by shulianyong on 13-12-1.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "ConfirmMunePassword.h"
#import "LockInfo.h"
#import "CommonUtil.h"

@interface ConfirmMunePassword ()<UIAlertViewDelegate>
{
    MenuPasswordValidBlock validCallback;
}


@end

@implementation ConfirmMunePassword

+ (ConfirmMunePassword*)shareInstance
{
    static ConfirmMunePassword *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ConfirmMunePassword alloc] init];
    });
    
    return instance;
}

- (void)alertPassword:(NSString*)title withMessage:(NSString*)aMsg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:aMsg delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:MyLocalizedString(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    UITextField *txtPassword = [alert textFieldAtIndex:0];
    txtPassword.keyboardType = UIKeyboardTypeNumberPad;
    
    [alert show];
}

- (void)confirmMunePassword:(MenuPasswordValidBlock)aResultBlock
{
    validCallback = aResultBlock;
    [self alertPassword:nil withMessage:MyLocalizedString(@"Please enter the menu password")];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        BOOL success = NO;
        
        UITextField *txtPassword = [alertView textFieldAtIndex:0];
        NSString *password = txtPassword.text;
        if (![NSString isEmpty:password])
        {
            if ([password isEqualToString:[LockInfo shareInstance].univeral_passwd] || [password isEqualToString:[LockInfo shareInstance].passwd]) {
                success = YES;
                validCallback(success);
                
                NSNumber *isRemind = [[NSUserDefaults standardUserDefaults] objectForKey:@"STB_RemindUpgrade"];
                if (isRemind==nil) {
                    isRemind = @(YES);
                    [[NSUserDefaults standardUserDefaults] setObject:isRemind forKey:@"STB_RemindUpgrade"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
        if (!success) {
            [self alertPassword:nil withMessage:MyLocalizedString(@"The password is not correct,please reenter")];
        }
    }
}

@end
