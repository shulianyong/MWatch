//
//  LockInfo.h
//  STB
//
//  Created by shulianyong on 13-11-1.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LockInfo : NSObject

//{
//    "result": 0,
//    "commandId": 111,
//    "passwd": "0000",
//    "channel_lock": 1,
//    "error": "",
//    "command": "bs_get_lock_control",
//    "menu_lock": 0,
//    "passwd_channel": "0000",
//    "univeral_passwd": "8765"
//}

//
//menu_lock:机顶盒菜单锁是否打开 channel_lock:机顶盒节目锁时候打开
//passwd:即为一级密码 passwd_channel:即为二级密码,用以控制播放节目的密码 univeral_passwd:万能密码,不能修改,此密码针对菜单和节目密码均有效

+ (LockInfo*)shareInstance;

@property (nonatomic,strong) NSNumber *result;
@property (nonatomic,strong) NSNumber *commandId;
@property (nonatomic,strong) NSString *passwd;
@property (nonatomic,strong) NSNumber *channel_lock;
@property (nonatomic,strong) NSString *error;
@property (nonatomic,strong) NSString *command;
@property (nonatomic,strong) NSNumber *menu_lock;
@property (nonatomic,strong) NSString *passwd_channel;
@property (nonatomic,strong) NSString *univeral_passwd;

@end
