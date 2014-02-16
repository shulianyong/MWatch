//
//  ConfirmUtil.m
//  STB
//
//  Created by shulianyong on 13-12-1.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "ConfirmUtil.h"

@interface ConfirmUtil ()
{
    UIAlertView *confirmView;
}


@property (nonatomic,strong) dispatch_block_t OKBlock;
@property (nonatomic,strong) dispatch_block_t CancelBlock;

@end

@implementation ConfirmUtil

+ (instancetype)Util
{
    ConfirmUtil *util = [[ConfirmUtil alloc] init];
    return util;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        self.OKBlock();
        confirmView = nil;
    }
    else
    {
        self.CancelBlock();
        confirmView = nil;
    }
}


- (void)showConfirmWithTitle:(NSString*)aTitle
                 withMessage:(NSString*)aMsg
                 WithOKBlcok:(dispatch_block_t)okBlock
             withCancelBlock:(dispatch_block_t)cancelBlock
{
    if(confirmView)
        return;
    self.OKBlock = okBlock;
    self.CancelBlock = cancelBlock;
    confirmView = [[UIAlertView alloc] initWithTitle:aTitle==nil?MyLocalizedString(@"Alert"):aTitle
                                                          message:aMsg
                                                         delegate:self
                                                cancelButtonTitle:MyLocalizedString(@"Cancel")
                                                otherButtonTitles:MyLocalizedString(@"OK"), nil];
    [confirmView show];
}

@end
