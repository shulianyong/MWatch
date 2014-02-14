//
//  InputAlert.m
//  STB
//
//  Created by shulianyong on 13-12-27.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "InputAlert.h"

@interface InputAlert ()<UIAlertViewDelegate>
{
    InputBlock resultCallback;
}

@end

@implementation InputAlert



+ (InputAlert*)shareInstance
{
    static InputAlert *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InputAlert alloc] init];
    });
    
    return instance;
}

- (void)alertMessage:(NSString*)aMsg withResultBlock:(InputBlock)aBlock
{
    resultCallback = aBlock;    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:aMsg delegate:self cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:MyLocalizedString(@"OK"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        UITextField *txtValue = [alertView textFieldAtIndex:0];
        NSString *inputValue = txtValue.text;
        if (![NSString isEmpty:inputValue])
        {
            resultCallback(inputValue);
        }
    }
}

+ (void)alertMessage:(NSString*)aMsg withResultBlock:(InputBlock)aBlock
{
    [[self shareInstance] alertMessage:aMsg withResultBlock:aBlock];
}


@end
