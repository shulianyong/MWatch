//
//  ViewController.m
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "ViewController.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <arpa/inet.h>
#include <netdb.h>
#include <ifaddrs.h>
#import <dlfcn.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import "UIViewController+JASidePanel.h"
#import "JASidePanelController.h"

#import "KxMovieViewController.h"
#import <MediaPlayer/MPVolumeView.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import "KxAudioManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSString *path = @"http://santai.tv/vod/test/test_format_1.mp4";
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
        
        id<KxAudioManager> audioManager = [KxAudioManager audioManager];
        [audioManager activateAudioSession];
//        [self configMoviePath:path parameters:parameters];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:<#(CGRect)#>];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)click_barBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)click_barChannel:(id)sender {
    [self.sidePanelController showLeftPanel:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation NS_DEPRECATED_IOS(2_0, 6_0)
{
    BOOL ret = NO;
    
    ret = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)|(toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    
    return ret;
}


- (BOOL)shouldAutorotate
{
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIViewController attemptRotationToDeviceOrientation];
    BOOL hidden =!(self.navigationController.navigationBarHidden);
    [self.navigationController setNavigationBarHidden:hidden animated:YES];
    [self.tbarBottom setHidden:hidden];
    
    NSLog(@"macaddress:%@",[self getIPAddress]);
}

- (NSString *)getIPAddress
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
                    NSString *mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];
                    NSLog(@"mask:%@",mask);
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"]) // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

- (NSString *) hostname
{
    char baseHostName[256]; // Thanks, Gunnar Larisch
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
//    baseHostName[255] = '/0';
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@'%s', baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}




- (NSString *) localIPAddress
{
    struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
}

- (NSString *) whatismyipdotcom
{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://www.whatismyip.com/automation/n09230945.asp"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:1 error:&error];
    return ip ? ip : [error localizedDescription];
}

- (IBAction)click_Play:(id)sender {
    
    NSString *path = @"http://santai.tv/vod/test/test_format_1.mp4";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
     parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
                                                                               parameters:parameters];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (IBAction)click_Volume:(id)sender {
    static float volume = 0.1;
    volume+=0.1;
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = volume;
}

- (IBAction)click_next:(id)sender {
    
    MPVolumeView *myVolumeView =[[MPVolumeView alloc] initWithFrame: CGRectMake(20, 50, 200,30)];
    myVolumeView.showsVolumeSlider = YES;
    myVolumeView.showsRouteButton = YES;
    [myVolumeView sizeToFit];
    [self.view addSubview: myVolumeView];
    
}
@end
