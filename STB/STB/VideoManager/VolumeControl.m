//
//  VolumeControl.m
//  STB
//
//  Created by shulianyong on 13-11-10.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "VolumeControl.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation VolumeControl

+ (VolumeControl*)shareInstance
{
    static VolumeControl *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[VolumeControl alloc] init];
    });
    
    return instance;
}

#pragma mark －－－－－－－－－－－－－－－－－－－－－
#pragma mark －－－－－－－－－－－－－－－－－－－－－ 静音设置

- (BOOL)isMuted
{
    CFStringRef route;
    UInt32 routeSize = sizeof(CFStringRef);
    
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route);
    if (status == kAudioSessionNoError)
    {
        if (route == NULL || !CFStringGetLength(route))
            return TRUE;
    }
    
    return FALSE;
}

- (BOOL)addMutedListener
{
    OSStatus s = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                                 audioRouteChangeListenerCallback,
                                                 (__bridge void *)(self));
    return s == kAudioSessionNoError;
}

void audioRouteChangeListenerCallback (void *inUserData,
                                       AudioSessionPropertyID inPropertyID,
                                       UInt32 inPropertyValueSize,
                                       const void *inPropertyValue
                                       )
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
//    BOOL muted = [[VolumeControl shareInstance] isMuted];
    
    // add code here
}




@end
