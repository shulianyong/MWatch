//
//  AudioTrack.h
//  STB
//
//  Created by shulianyong on 13-10-20.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioTrack : NSObject

@property (nonatomic) NSInteger audioId;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *desc;

@end

@protocol AudioTrack;
@interface AudioTrackSection : NSObject

@property (nonatomic) NSInteger type;
@property (nonatomic,strong) NSString *sectionName;
@property (nonatomic,strong) NSArray *audioTracks;

@end
