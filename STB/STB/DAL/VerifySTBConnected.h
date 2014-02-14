//
//  VerifySTBConnected.h
//  STB
//
//  Created by shulianyong on 14-1-17.
//  Copyright (c) 2014年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VerifySTBConnectedDelegate <NSObject>

- (void)ConnectedSTBSuccess;
- (void)ConnectedSTBFail;

@end

@interface VerifySTBConnected : NSObject

+ (void)verifyConnectedWithBackDelegate:(id<VerifySTBConnectedDelegate>)aDelegate;

@end
