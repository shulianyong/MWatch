//
//  InputAlert.h
//  STB
//
//  Created by shulianyong on 13-12-27.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^InputBlock)(NSString *aResult);
@interface InputAlert : NSObject

+ (void)alertMessage:(NSString*)aMsg withResultBlock:(InputBlock)aBlock;

@end
