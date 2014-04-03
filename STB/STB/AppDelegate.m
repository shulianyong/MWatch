//
//  AppDelegate.m
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "AppDelegate.h"

#import "CommandClient.h"
#import "UPNPTool.h"
#import "VideoController.h"
#import "VerifySTBConnected.h"
#import "STBSystemInfo.h"
#import "CommonUtil.h"

#import "STBVersionCheck.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [VersionUpdate DefaultSTB];
//    [check checkSTBUPdateVersion];
//    [CommandClient getInternetSTBInfo:^(id info, HTTPAccessState isSuccess) {
//        
//    }];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.]]
    [[NSNotificationCenter defaultCenter] postNotificationName:PauseNotification object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //设置过期时间
    NSDate *saveTime = [[NSUserDefaults standardUserDefaults] objectForKey:ExpiredTimeUserDefault];
    NSDate *dateNow = [NSDate date];
    if (saveTime==nil) {
        saveTime = dateNow;
    }
    else if (saveTime.timeIntervalSince1970<dateNow.timeIntervalSince1970) {
        saveTime = dateNow;
    }
    [[NSUserDefaults standardUserDefaults] setObject:saveTime forKey:ExpiredTimeUserDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //每次进行，都进行upnp扫描
    
    id<VerifySTBConnectedDelegate> tvManager = (id<VerifySTBConnectedDelegate>)self.window.rootViewController;
    [VerifySTBConnected verifyConnectedWithBackDelegate:tvManager];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayNotification object:nil];
    
    
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
