//
//  SingleAlert.m
//  STB
//
//  Created by shulianyong on 13-12-16.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "SingleAlert.h"

@implementation SingleAlert

+ (SingleAlert*)shareInstance
{
    static SingleAlert *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SingleAlert alloc] init];
    });
    
    return instance;
}

- (id)init
{
    static SingleAlert *instance = nil;
    if (instance==nil) {
        instance = [super init];
    }
    self = instance;
    if (self) {
    }
    return self;
}


- (void)setAlertView:(UIAlertView *)alertView
{
    if (_alertView!=nil) {
        __block UIAlertView *tempAlert = _alertView;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
        [tempAlert dismissWithClickedButtonIndex:0 animated:YES];
            });
        });
    }
    _alertView = alertView;
}



- (void)showMessage:(NSString*)aMessgae
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert") message:aMessgae delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:nil];
    self.alertView = alertView;
    __weak SingleAlert *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.alertView show];
        });
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.alertView = nil;
}


+ (void)showMessage:(NSString*)aMessgae
{
    [SingleAlert.shareInstance showMessage:aMessgae];
}

@end
