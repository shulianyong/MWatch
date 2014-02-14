//
//  PasswordAlert.m
//  STB
//
//  Created by shulianyong on 13-11-18.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "PasswordAlert.h"
#import "LockInfo.h"
#import "CommonUtil.h"
#import "../../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"

@interface PasswordAlert ()<UIAlertViewDelegate>
{
    ValidPasswordCallback validCallback;
}

@end

@implementation PasswordAlert

+ (PasswordAlert*)shareInstance
{
    static PasswordAlert *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PasswordAlert alloc] init];
    });
    
    return instance;
}

- (void)alertPassword:(NSString*)title withMessage:(NSString*)aMsg withValidPasswordCallback:(ValidPasswordCallback)validPassword
{
    validCallback = validPassword;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:aMsg delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:MyLocalizedString(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        BOOL success = NO;
        
        UITextField *txtPassword = [alertView textFieldAtIndex:0];
        NSString *password = txtPassword.text;
        if (![NSString isEmpty:password]) {
            success = validCallback(self,password);
        }
        if (!success) {
            [self alertPassword:nil withMessage:MyLocalizedString(@"The password is not correct,please reenter") withValidPasswordCallback:validCallback];
        }
    }
}

@end
