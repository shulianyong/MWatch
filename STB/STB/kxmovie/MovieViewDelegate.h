//
//  MovieViewDelegate.h
//  STB
//
//  Created by shulianyong on 13-10-13.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

//错误码，现在我只例了这三个，你按你那里的需求，可以多例些
typedef enum PlayerFailType {
    PlayerFailNone = 0,
    NetworkDisconnetionType,
    LoadingFailType,
    DecodeFailType,
    PlayerReplayFail,
}_PlayerFailType;

@protocol MovieViewProtocol;
//回调协议，
@protocol MovieViewDelegate <NSObject>

//播放失败，在播放失败时，调用该方法
- (void)fail:(_PlayerFailType)aFailType withPlay:(id<MovieViewProtocol>)aPlayer;

//正在加载,在接收到播放请求后，从网络中获取 视频数据时，返回的百分比
- (void)loading:(NSString*)aPercent withPlay:(id<MovieViewProtocol>)aPlayer;

//加载结束，并且播放时，回调
- (void)loadend:(id<MovieViewProtocol>)aPlayer;


@end

//播放器需要的公共的接口
//你需要实现一个UIView,继承这个协议
@protocol MovieViewProtocol <NSObject>

//路径
@property (nonatomic,strong)  NSString *channelPath;

//委托对象
@property (nonatomic,weak) id<MovieViewDelegate> movieDelegate;
//设置播放器界面的长，度，位置
- (void)configScreenFrame:(CGRect)aFrame;
//双击全屏
- (void)fullScreen;

- (void) playVideo;
- (void) pauseVideo;
- (void) rewind;
- (void) forward;
- (void) stopVideo;
- (void) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters;

@end
