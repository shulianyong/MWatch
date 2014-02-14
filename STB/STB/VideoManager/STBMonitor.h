//
//  STBMonitor.h
//  STB
//
//  Created by shulianyong on 13-10-23.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//




#import <Foundation/Foundation.h>
@class STBMonitor;


typedef NS_ENUM(NSInteger, MonitorType) {
    MonitorNone          = 0,
    SignalStrengthType     = 1,
};



@protocol STBMonitorProtocol <NSObject>

- (void)STBMonitor:(STBMonitor*)aMonitor withMonitorType:(MonitorType)aType;

@end

@interface STBMonitor : NSObject

@property (nonatomic,weak) id<STBMonitorProtocol> monitorDelegate;

+ (STBMonitor*)shareInstance;

//事件监听
- (void)eventMonitor;

@end
