//
//  Channel.h
//  STB
//
//  Created by shulianyong on 13-10-17.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Channel : NSManagedObject
{
    NSNumber *tempSelected;
}

@property (nonatomic, retain) NSNumber * audioEcmPid;
@property (nonatomic, retain) NSNumber * audioMode;
@property (nonatomic, retain) NSNumber * audioPid;
@property (nonatomic, retain) NSNumber * audioType;
@property (nonatomic, retain) NSNumber * audioVolume;
@property (nonatomic, retain) NSNumber * casId;
@property (nonatomic, retain) NSNumber * definition;
@property (nonatomic, retain) NSNumber * lock;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * originalId;
@property (nonatomic, retain) NSNumber * pcrPid;
@property (nonatomic, retain) NSNumber * pmtPid;
@property (nonatomic, retain) NSNumber * satId;
@property (nonatomic, retain) NSNumber * scrambled;
@property (nonatomic, retain) NSNumber * serviceId;
@property (nonatomic, retain) NSNumber * serviceType;
@property (nonatomic, retain) NSNumber * skip;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * tpId;
@property (nonatomic, retain) NSNumber * tsId;
@property (nonatomic, retain) NSNumber * videoEcmPid;
@property (nonatomic, retain) NSNumber * videoPid;
@property (nonatomic, retain) NSNumber * videoType;
@property (nonatomic, retain) NSNumber * bouquetId;
@property (nonatomic, retain) NSNumber * channelId;
@property (nonatomic, retain) NSNumber * groupNum;
@property (nonatomic, retain) NSNumber * lcn;
@property (nonatomic, retain) NSNumber * subtitlePid;
@property (nonatomic, retain) NSNumber * subtitleType;
@property (nonatomic, retain) NSNumber * teletextPid;

@property (nonatomic,strong) NSNumber *tempSelected;

@end
