//
//  ConfirmMunePassword.h
//  STB
//
//  Created by shulianyong on 13-12-1.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MenuPasswordValidBlock)(BOOL aResult);
@interface ConfirmMunePassword : NSObject

+ (ConfirmMunePassword*)shareInstance;
- (void)confirmMunePassword:(MenuPasswordValidBlock)aResultBlock;

@end
