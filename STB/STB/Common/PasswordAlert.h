//
//  PasswordAlert.h
//  STB
//
//  Created by shulianyong on 13-11-18.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PasswordAlert;

typedef BOOL(^ValidPasswordCallback)(PasswordAlert *aAlert,NSString *password);

@interface PasswordAlert : NSObject

+ (PasswordAlert*)shareInstance;

- (void)alertPassword:(NSString*)title withMessage:(NSString*)aMsg withValidPasswordCallback:(ValidPasswordCallback)validPassword;

@end
