//
//  SignalTool.h
//  STB
//
//  Created by shulianyong on 13-11-15.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SignalDelegate <NSObject>

- (void)noSignal;

- (void)hasSignal;

@end

@class STBPlayer;
@interface SignalTool : NSObject<SignalDelegate>

+ (SignalTool*)shareInstance;

@end
