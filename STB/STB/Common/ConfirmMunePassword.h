//
//  ConfirmMunePassword.h
//  STB
//
//  Created by shulianyong on 13-12-1.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MenuPasswordValidBlock)(BOOL aResult);
@interface ConfirmMunePassword : NSObject

+ (ConfirmMunePassword*)shareInstance;
- (void)confirmMunePassword:(MenuPasswordValidBlock)aResultBlock;

@end
