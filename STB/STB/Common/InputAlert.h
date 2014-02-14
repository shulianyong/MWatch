//
//  InputAlert.h
//  STB
//
//  Created by shulianyong on 13-12-27.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^InputBlock)(NSString *aResult);
@interface InputAlert : NSObject

+ (void)alertMessage:(NSString*)aMsg withResultBlock:(InputBlock)aBlock;

@end
