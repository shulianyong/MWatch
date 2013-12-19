//
//  SignalTool.m
//  STB
//
//  Created by shulianyong on 13-11-15.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "SignalTool.h"
#import "MBProgressHUD.h"
#import "STBPlayer.h"
#import "CommonUtil.h"

@interface SignalTool ()

@property (nonatomic,strong) UIAlertView *alert;

@end

@implementation SignalTool

+ (SignalTool*)shareInstance
{
    static SignalTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SignalTool alloc] init];
    });
    return instance;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.alert = nil;
}

- (void)noSignal
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PauseNotification object:nil];   
    if (self.alert) {
        return;
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.alert = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"NO Signal") message:nil delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:nil];
            [self.alert show];

        });
        
    }
    
}

- (void)hasSignal
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayNotification object:nil];
    if (self.alert) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
            self.alert = nil;
        });
    }
}

@end
