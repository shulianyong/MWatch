//
//  PasswordAlert.h
//  STB
//
//  Created by shulianyong on 13-11-18.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PasswordAlert;

typedef BOOL(^ValidPasswordCallback)(PasswordAlert *aAlert,NSString *password);

@interface PasswordAlert : NSObject

+ (PasswordAlert*)shareInstance;

- (void)alertPassword:(NSString*)title withMessage:(NSString*)aMsg withValidPasswordCallback:(ValidPasswordCallback)validPassword;

@end
