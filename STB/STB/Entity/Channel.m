//
//  Channel.m
//  STB
//
//  Created by shulianyong on 13-10-17.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import "Channel.h"


@implementation Channel

@synthesize tempSelected = tempSelected;

@dynamic audioEcmPid;
@dynamic audioMode;
@dynamic audioPid;
@dynamic audioType;
@dynamic audioVolume;
@dynamic casId;
@dynamic definition;
@dynamic lock;
@dynamic name;
@dynamic originalId;
@dynamic pcrPid;
@dynamic pmtPid;
@dynamic satId;
@dynamic scrambled;
@dynamic serviceId;
@dynamic serviceType;
@dynamic skip;
@dynamic timeStamp;
@dynamic tpId;
@dynamic tsId;
@dynamic videoEcmPid;
@dynamic videoPid;
@dynamic videoType;
@dynamic bouquetId;
@dynamic channelId;
@dynamic groupNum;
@dynamic lcn;
@dynamic subtitlePid;
@dynamic subtitleType;
@dynamic teletextPid;

- (NSNumber*)tempSelected
{
    if (tempSelected==nil) {
        tempSelected = [NSNumber numberWithBool:self.lock.boolValue];
    }
    return tempSelected;
}

@end
