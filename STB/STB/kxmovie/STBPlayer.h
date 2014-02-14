//
//  STBPlayer.h
//  STB
//
//  Created by shulianyong on 13-10-13.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieViewDelegate.h"
@class KxMovieDecoder;

extern NSString * const ParameterMinBufferedDuration;    // Float
extern NSString * const ParameterMaxBufferedDuration;    // Float
extern NSString * const ParameterDisableDeinterlacing;   // BOOL


@interface STBPlayer : UIView<MovieViewProtocol,UITableViewDataSource,UITableViewDelegate>

@property BOOL playing;
@property BOOL paused;
- (void) playVideo;
- (void) play;
- (void) pause;
- (void) rewind;
- (void) forward;
- (void) stopVideo;
- (void) audioTrack;
- (NSDictionary*)audioTracks;
- (void) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters;


//做为data table时需要的controller
@property (nonatomic,weak) UIViewController *controllerDelegate;

//设置最大分析时间
//分析时间
@property (nonatomic) NSInteger maxAnalyzeDuration;

- (void)didReceiveMemoryWarning;

@end
