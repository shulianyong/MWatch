//
//  CommonUtil.m
//  STB
//
//  Created by shulianyong on 13-10-14.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "CommonUtil.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@implementation CommonUtil

+ (NSString*)serverIP
{
    NSString *ip = nil;
    
    NSString *tempIP = [self getIPAddress];
    if (tempIP!=nil || tempIP.length>0) {
        NSMutableArray *ipPoint = [NSMutableArray arrayWithArray: [tempIP componentsSeparatedByString:@"."]];
        NSInteger count = [ipPoint count];
        [ipPoint replaceObjectAtIndex:count-1 withObject:@"1"];
        tempIP = [ipPoint componentsJoinedByString:@"."];
    }
    else
    {
        tempIP = @"";
    }
    ip = tempIP;
    
    return ip;
}

+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0; // retrieve the current interfaces - returns 0 on success
    
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                    NSString *mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
//                    NSLog(@"mask:%@",mask);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (void)showMessage:(NSString*)aMessgae
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert") message:aMessgae delegate:nil cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:nil];
    [alertView show];
}


+ (void)showMessage:(NSString*)aMessgae withCannelBlock:(dispatch_block_t)aBlock
{    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert") message:aMessgae delegate:nil cancelButtonTitle:MyLocalizedString(@"Cancel") otherButtonTitles:nil];
    [alertView show];
}

#pragma mark ---------过期

//是否在有效期内
+ (BOOL)expired
{
	static NSDateFormatter *formatter = nil;
	if (formatter == nil)  {
		formatter = [[NSDateFormatter alloc] init];
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:enUS];
		[formatter setDateFormat:@"yyyy-MM-dd"];
	}
    
    //设置有效期
    NSString *validString = ExpiredTime;
    NSDate *validDate = [formatter dateFromString:validString];
    
    NSDate *saveTime = [[NSUserDefaults standardUserDefaults] objectForKey:ExpiredTimeUserDefault];
    NSDate *nowtime = [NSDate date];
    
    
    BOOL expired = NO;
    if (saveTime.timeIntervalSince1970>nowtime.timeIntervalSince1970 ||
        nowtime.timeIntervalSince1970>validDate.timeIntervalSince1970)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MyLocalizedString(@"Alert")
                                                        message:MyLocalizedString(@"Version is expired")
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        expired = YES;
    }
    return expired;
}


@end
