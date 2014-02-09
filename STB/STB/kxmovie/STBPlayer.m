//
//  STBPlayer.m
//  STB
//
//  Created by shulianyong on 13-10-13.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "STBPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoder.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"

#import "AudioTrack.h"
NSString * const ParameterMinBufferedDuration = @"KxMovieParameterMinBufferedDuration";
NSString * const ParameterMaxBufferedDuration = @"KxMovieParameterMaxBufferedDuration";
NSString * const ParameterDisableDeinterlacing = @"KxMovieParameterDisableDeinterlacing";

//是否全屏
static BOOL isFullScreen;

static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSString *ret = [NSString stringWithFormat:@"%@%d:%0.2d:%0.2d", isLeft ? @"-" : @"", h,m,s];
    
    
    return ret;
}


////////////////////////////////////////////////////////////////////////////////

enum {
    
    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,
    KxMovieInfoSectionCount,
};

enum {
    
    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   2.0
#define LOCAL_MAX_BUFFERED_DURATION   4.0

#warning buffer
static CGFloat NETWORK_MIN_BUFFERED_DURATION = 1.0;
static CGFloat NETWORK_MAX_BUFFERED_DURATION = 3.0;
@interface STBPlayer ()
{
    
    CGFloat             _moviePosition;
    KxMovieDecoder      *_decoder;
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
    NSMutableArray      *_audioFrames;
    NSMutableArray      *_subtitles;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    BOOL                _disableUpdateHUD;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSUInteger          _tickCounter;
    BOOL                _fullscreen;
    BOOL                _hiddenHUD;
    BOOL                _fitMode;
    BOOL                _infoMode;
    BOOL                _restoreIdleTimer;
    BOOL                _interrupted;
    
    KxMovieGLView       *_glView;
    UIImageView         *_imageView;
    UISlider            *_progressSlider;
    MPVolumeView        *_volumeSlider;
    UIButton            *_playButton;
    UIButton            *_rewindButton;
    UIButton            *_forwardButton;
    UIButton            *_doneButton;
    UILabel             *_progressLabel;
    UILabel             *_leftLabel;
    UIButton            *_infoButton;
    UITableView         *_tableView;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel             *_subtitlesLabel;
    
    UITapGestureRecognizer *_tapGestureRecognizer;
    UITapGestureRecognizer *_doubleTapGestureRecognizer;
    UIPanGestureRecognizer *_panGestureRecognizer;
    
#ifdef DEBUG
    UILabel             *_messageLabel;
    NSTimeInterval      _debugStartTime;
    NSUInteger          _debugAudioStatus;
    NSDate              *_debugAudioStatusTS;
#endif
    
    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    
    BOOL                _savedIdleTimer;
    
    NSDictionary        *_parameters;
}

//播放器的openGL用于渲染的界面
@property (strong,nonatomic) KxMovieGLView *playerView;
@property (readwrite) BOOL decoding;
@property (readwrite, strong) KxArtworkFrame *artworkFrame;


//音轨table
@property (nonatomic,weak) UITableView *audioAtrackTable;
@end

@implementation STBPlayer

//路径，由使用者给
@synthesize channelPath;

//委托对象，由使用者给
@synthesize movieDelegate;

#pragma mark --------------------- 公共方法
+ (void)initialize
{
    if (!gHistory)
        gHistory = [NSMutableDictionary dictionary];
}

#pragma mark ----初始化

//- (void)configMoviePath: (NSString *) path
//             parameters: (NSDictionary *) parameters
//{
//    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
//    [audioManager activateAudioSession];
//    _moviePosition = 0;
//    _parameters = parameters;
//    
//    __weak STBPlayer *weakSelf = self;
//    
//    KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
//    
//    decoder.interruptCallback = ^BOOL(){
//        
//        __strong STBPlayer *strongSelf = weakSelf;
//        return strongSelf ? [strongSelf interruptDecoder] : YES;
//    };
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//        NSError *error = nil;
//        [decoder openFile:path error:&error];
//        
//        __strong STBPlayer *strongSelf = weakSelf;
//        if (strongSelf) {
//            
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                
//                [strongSelf setMovieDecoder:decoder withError:error];
//            });
//        }
//    });
//}

//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        
//    }
//    return self;
//}

- (void) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters
{
    NSAssert(path.length > 0, @"empty path");
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = self.center;
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self addSubview:_activityIndicatorView];
    [_activityIndicatorView startAnimating];
    if (self) {
        _moviePosition = 0;        
        _parameters = parameters;
        
        __weak STBPlayer *weakSelf = self;
        
        KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
        //设置最大分析时间
        if (self.maxAnalyzeDuration>0) {
            decoder.maxAnalyzeDuration = self.maxAnalyzeDuration;
        }
        
        decoder.interruptCallback = ^BOOL(){
            return weakSelf ? [weakSelf interruptDecoder] : YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSError *error = nil;
            [decoder openFile:path error:&error];
            if (weakSelf) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf setMovieDecoder:decoder withError:error];
                });
            }
        });
    }
}
- (void)loadView
{
    // NSLog(@"loadView");
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
#warning _activityIndicatorView
    CGFloat width = bounds.size.width;
    //    CGFloat height = bounds.size.height;
    
#ifdef DEBUG
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,40,width-40,40)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor redColor];
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.numberOfLines = 2;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_messageLabel];
#endif
}

#warning 内容释放
- (void)didReceiveMemoryWarning
{
    
    if (self.playing) {
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            NSLog(@"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    
    [self showHUD: YES];
    
    if (_decoder) {
        
        [self restorePlay];
        
    } else {
        
        [_activityIndicatorView startAnimating];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
}

- (void) dealloc
{
    NSLog(@"%s", __func__);
    [self pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_dispatchQueue) {
        _dispatchQueue = NULL;
    }
}

- (void) Disappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_activityIndicatorView stopAnimating];
    
    if (_decoder) {
        
        [self pause];
        
        if (_moviePosition == 0 || _decoder.isEOF)
            [gHistory removeObjectForKey:_decoder.path];
        else if (!_decoder.isNetwork)
            [gHistory setValue:[NSNumber numberWithFloat:_moviePosition]
                        forKey:_decoder.path];
    }
    
    if (_fullscreen)
        [self fullscreenMode:NO];
    
//    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    [_activityIndicatorView stopAnimating];
    _buffered = NO;
    _interrupted = YES;
    
    NSLog(@"viewWillDisappear %@", self);
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}
//
- (void) applicationWillResignActive: (NSNotification *)notification
{
    [self showHUD:YES];
    [self pause];
    
    NSLog(@"applicationWillResignActive");
}

#pragma mark - public

-(void) play
{
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio) {
        
        return;
    }
    self.paused = NO;
    if (_interrupted)
        return;
    
    self.playing = YES;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    [self updatePlayButton];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    if (_decoder.validAudio)
        [self enableAudio:YES];
    
    NSLog(@"play movie");
     [self.movieDelegate loadend:self];
}

- (void) pause
{
    if (!self.playing)
        return;
    self.paused = YES;
    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    [self updatePlayButton];
    NSLog(@"pause movie");
    NSLog(@"vedio Path:%@",_decoder.path);
}

- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    _disableUpdateHUD = YES;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - actions

- (void)stop
{
}

- (void) playDidTouch: (id) sender
{
    if (self.playing)
        [self pause];
    else
        [self play];
}

- (void) forwardDidTouch: (id) sender
{
    [self setMoviePosition: _moviePosition + 10];
}

- (void) rewindDidTouch: (id) sender
{
    [self setMoviePosition: _moviePosition - 10];
}
- (void) infoDidTouch
{
    [self showInfoView: !_infoMode animated:YES];
}

- (void) progressDidChange: (id) sender
{
    NSAssert(_decoder.duration != MAXFLOAT, @"bugcheck");
    UISlider *slider = sender;
    [self setMoviePosition:slider.value * _decoder.duration];
}

#pragma mark - private

- (void) setMovieDecoder: (KxMovieDecoder *) decoder
               withError: (NSError *) error
{
    NSLog(@"setMovieDecoder");
    
    if (!error && decoder) {
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
        if (_decoder.subtitleStreamsCount) {
            _subtitles = [NSMutableArray array];
        }
        
        if (_decoder.isNetwork) {
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if (_parameters.count) {
            
            id val;
            
            val = [_parameters valueForKey: ParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: ParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey:ParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        NSLog(@"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        
        [self setupPresentView];
        _progressLabel.hidden   = NO;
        _progressSlider.hidden  = NO;
        _leftLabel.hidden       = NO;
        _infoButton.hidden      = NO;
        
        if (_activityIndicatorView.isAnimating) {
            
            [_activityIndicatorView stopAnimating];
            // if (self.view.window)
            [self restorePlay];
        }        
    }
    else
    {
        [_activityIndicatorView stopAnimating];
        if (!_interrupted)
        {
            [self.movieDelegate fail:DecodeFailType withPlay:self];
        }
    }
}

- (void) restorePlay
{
    NSNumber *n = [gHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

- (void) setupPresentView
{
    CGRect bounds = self.bounds;
    
    if (_decoder.validVideo) {
        _glView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
        _glView.backgroundColor = [UIColor blackColor];
    }
    
    if (!_glView) {
        
        NSLog(@"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:bounds];
    }
    
    
    
    UIView *frameView = [self frameView];
    frameView.contentMode = isFullScreen?UIViewContentModeScaleAspectFill:UIViewContentModeScaleAspectFit;
    frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [self insertSubview:frameView atIndex:0];
    
    if (_decoder.validVideo) {        
    } else {
        
        _imageView.image = [UIImage imageNamed:@"kxmovie.bundle/music_icon.png"];
        _imageView.contentMode = UIViewContentModeCenter;
    }
    
    //    self.backgroundColor = [UIColor clearColor];
    
    if (_decoder.duration == MAXFLOAT) {
        
        _leftLabel.text = @"\u221E"; // infinity
        _leftLabel.font = [UIFont systemFontOfSize:14];
        
        CGRect frame;
        
        frame = _leftLabel.frame;
        frame.origin.x += 40;
        frame.size.width -= 40;
        _leftLabel.frame = frame;
        
        frame =_progressSlider.frame;
        frame.size.width += 40;
        _progressSlider.frame = frame;
        
    } else {
        
        [_progressSlider addTarget:self
                            action:@selector(progressDidChange:)
                  forControlEvents:UIControlEventValueChanged];
    }
    
    if (_decoder.subtitleStreamsCount) {
        
        CGSize size = self.bounds.size;
        
        _subtitlesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height, size.width, 0)];
        _subtitlesLabel.numberOfLines = 0;
        _subtitlesLabel.backgroundColor = [UIColor clearColor];
        _subtitlesLabel.opaque = NO;
        _subtitlesLabel.adjustsFontSizeToFitWidth = NO;
        _subtitlesLabel.textAlignment = NSTextAlignmentCenter;
        _subtitlesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _subtitlesLabel.textColor = [UIColor whiteColor];
        _subtitlesLabel.font = [UIFont systemFontOfSize:16];
        _subtitlesLabel.hidden = YES;
        
        [self addSubview:_subtitlesLabel];
    }
}


- (UIView *) frameView
{
    return _glView ? _glView : _imageView;
}

- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrame *frame = _audioFrames[0];
                        
                        if (_decoder.validVideo) {
                            
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -2.0) {
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
#ifdef DEBUG
                                NSLog(@"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 1;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 0.4 && count > 1) {
                                
#ifdef DEBUG
                                NSLog(@"desync audio (lags) skip %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 2;
                                _debugAudioStatusTS = [NSDate date];
#endif 
                                [_audioFrames removeObjectAtIndex:0];

                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //NSLog(@"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    
    if (on && _decoder.validAudio) {
        
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        NSLog(@"audio device smr: %d fmt: %d chn: %d",
              (int)audioManager.samplingRate,
              (int)audioManager.numBytesPerSample,
              (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames
{
    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrame *)frame;
        }
    }
    
    if (_decoder.validSubtitles) {
        
        @synchronized(_subtitles) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeSubtitle) {
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio) {
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count) {
        return [self addFrames: frames];
    }else{
        NSLog(@"Frame is nil");
    }
    return NO;
}

- (void) asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak STBPlayer *weakSelf = self;
    __weak KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            if (!weakSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                __strong KxMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)) {
                    
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count) {
                        if (weakSelf)
                            good = [weakSelf addFrames:frames];
                    }else{
                        NSLog(@"Frame is nil");
                    }
                }
            }
        }
        
        {
            if (weakSelf) weakSelf.decoding = NO;
        }
    });
}

- (void) tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
        
        _tickCorrectionTime = 0;
        _buffered = NO;
        [_activityIndicatorView stopAnimating];
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing) {
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0) +
        (_decoder.validAudio ? _audioFrames.count : 0);
        
        if (0 == leftFrames) {
            
            if (_decoder.isEOF) {
                [self pause];
                [self.movieDelegate fail:PlayerReplayFail withPlay:self];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered) {
                
                _buffered = YES;
                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)) {
            
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.playing) {
                [self tick];
            }
        });
    }
    
    if ((_tickCounter++ % 3) == 0) {
        [self updateHUD];
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    NSLog(@"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f) {
        
        NSLog(@"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat) presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames) {
            
            if (_videoFrames.count > 0) {
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {
        
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
    if (_decoder.validSubtitles)
        [self presentSubtitles];
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
}

- (CGFloat) presentVideoFrame: (KxVideoFrame *) frame
{
    if (_glView) {
        
        [_glView render:frame];
        
    } else {
        
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (void) presentSubtitles
{
    NSArray *actual, *outdated;
    
    if ([self subtitleForPosition:_moviePosition
                           actual:&actual
                         outdated:&outdated]){
        
        if (outdated.count) {
            @synchronized(_subtitles) {
                [_subtitles removeObjectsInArray:outdated];
            }
        }
        
        if (actual.count) {
            
            NSMutableString *ms = [NSMutableString string];
            for (KxSubtitleFrame *subtitle in actual.reverseObjectEnumerator) {
                if (ms.length) [ms appendString:@"\n"];
                [ms appendString:subtitle.text];
            }
            
            if (![_subtitlesLabel.text isEqualToString:ms]) {
                
                CGSize viewSize = self.bounds.size;
                CGSize size = [ms sizeWithFont:_subtitlesLabel.font
                             constrainedToSize:CGSizeMake(viewSize.width, viewSize.height * 0.5)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
                _subtitlesLabel.text = ms;
                _subtitlesLabel.frame = CGRectMake(0, viewSize.height - size.height - 10,
                                                   viewSize.width, size.height);
                _subtitlesLabel.hidden = NO;
            }
            
        } else {
            
            _subtitlesLabel.text = nil;
            _subtitlesLabel.hidden = YES;
        }
    }
}

- (BOOL) subtitleForPosition: (CGFloat) position
                      actual: (NSArray **) pActual
                    outdated: (NSArray **) pOutdated
{
    if (!_subtitles.count)
        return NO;
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (KxSubtitleFrame *subtitle in _subtitles) {
        
        if (position < subtitle.position) {
            
            break; // assume what subtitles sorted by position
            
        } else if (position >= (subtitle.position + subtitle.duration)) {
            
            if (pOutdated) {
                if (!outdated)
                    outdated = [NSMutableArray array];
                [outdated addObject:subtitle];
            }
            
        } else {
            
            if (pActual) {
                if (!actual)
                    actual = [NSMutableArray array];
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual) *pActual = actual;
    if (pOutdated) *pOutdated = outdated;
    
    return actual.count || outdated.count;
}

- (void) updatePlayButton
{
    [_playButton setImage:[UIImage imageNamed:self.playing ? @"kxmovie.bundle/playback_pause" : @"kxmovie.bundle/playback_play"]
                 forState:UIControlStateNormal];
}

- (void) updateHUD
{
    if (_disableUpdateHUD)
        return;
    
    const CGFloat duration = _decoder.duration;
    const CGFloat position = _moviePosition -_decoder.startTime;
    
    if (_progressSlider.state == UIControlStateNormal)
        _progressSlider.value = position / duration;
    _progressLabel.text = formatTimeInterval(position, NO);
    
    if (_decoder.duration != MAXFLOAT)
        _leftLabel.text = formatTimeInterval(duration - position, YES);
    
#ifdef DEBUG1
    const NSTimeInterval timeSinceStart = [NSDate timeIntervalSinceReferenceDate] - _debugStartTime;
    NSString *subinfo = _decoder.validSubtitles ? [NSString stringWithFormat: @" %d",_subtitles.count] : @"";
    
    NSString *audioStatus;
    
    if (_debugAudioStatus) {
        
        if (NSOrderedAscending == [_debugAudioStatusTS compare: [NSDate dateWithTimeIntervalSinceNow:-0.5]]) {
            _debugAudioStatus = 0;
        }
    }
    
    if (_debugAudioStatus == 1) audioStatus = @"\n(audio outrun)";
    else if (_debugAudioStatus == 2) audioStatus = @"\n(audio lags)";
    else if (_debugAudioStatus == 3) audioStatus = @"\n(audio silence)";
    else audioStatus = @"";
    
    _messageLabel.text = [NSString stringWithFormat:@"%d %d%@ %c - %@ %@ %@\n%@",
                          _videoFrames.count,
                          _audioFrames.count,
                          subinfo,
                          self.decoding ? 'D' : ' ',
                          formatTimeInterval(timeSinceStart, NO),
                          //timeSinceStart > _moviePosition + 0.5 ? @" (lags)" : @"",
                          _decoder.isEOF ? @"- END" : @"",
                          audioStatus,
                          _buffered ? [NSString stringWithFormat:@"buffering %.1f%%", _bufferedDuration / _minBufferedDuration * 100] : @""];
#endif
}

- (void) showHUD: (BOOL) show
{
    _hiddenHUD = !show;
    _panGestureRecognizer.enabled = _hiddenHUD;
    
//    [[UIApplication sharedApplication] setIdleTimerDisabled:_hiddenHUD];
    
    //    [UIView animateWithDuration:0.2
    //                          delay:0.0
    //                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
    //                     animations:^{
    //
    //                         CGFloat alpha = _hiddenHUD ? 0 : 1;
    //                         _topHUD.alpha = alpha;
    //                         _bottomHUD.alpha = alpha;
    //                     }
    //                     completion:nil];
    
}

- (void) fullscreenMode: (BOOL) on
{
    _fullscreen = on;
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:on withAnimation:UIStatusBarAnimationNone];
    // if (!self.presentingViewController) {
    //[self.navigationController setNavigationBarHidden:on animated:YES];
    //[self.tabBarController setTabBarHidden:on animated:YES];
    // }
}

- (void) setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void) setDecoderPosition: (CGFloat) position
{
    _decoder.position = position;
}

- (void) enableUpdateHUD
{
    _disableUpdateHUD = NO;
}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    __weak STBPlayer *weakSelf = self;
    
    dispatch_async(_dispatchQueue, ^{
        
        if (playMode) {
            
            {
                if (!weakSelf) return;
                [weakSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    [weakSelf setMoviePositionFromDecoder];
                    [weakSelf play];
                }
            });
            
        } else {
            
            {
                if (!weakSelf) return;
                [weakSelf setDecoderPosition: position];
                [weakSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    
                    [weakSelf enableUpdateHUD];
                    [weakSelf setMoviePositionFromDecoder];
                    [weakSelf presentFrame];
                    [weakSelf updateHUD];
                }
            });
        }
    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles) {
        @synchronized(_subtitles) {
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}
- (void) showInfoView: (BOOL) showInfo animated: (BOOL)animated
{
    if (!_tableView)
        [self createTableView];
    
    
    CGSize size = self.superview.superview.bounds.size;
    CGFloat Y = 0.0;
    
    if (showInfo) {
        [self pause];
        _tableView.hidden = NO;
        
        if (animated) {
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 _tableView.frame = CGRectMake(0,Y,size.width,size.height - Y);
                             }
                             completion:nil];
        } else {
            
            _tableView.frame = CGRectMake(0,Y,size.width,size.height - Y);
        }
        
    } else {
        [self play];
        if (animated) {
            
            [UIView animateWithDuration:0.4
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 _tableView.frame = CGRectMake(0,size.height,size.width,size.height - Y);
                                 
                             }
                             completion:^(BOOL f){
                                 
                                 if (f) {
                                     _tableView.hidden = YES;
                                 }
                             }];
        } else {
            
            _tableView.frame = CGRectMake(0,size.height,size.width,size.height - Y);
            _tableView.hidden = YES;
        }
    }
    
    _infoMode = showInfo;
}

- (void) createTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.superview.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.hidden = YES;
    
    CGSize size = self.superview.bounds.size;
    CGFloat Y = 0.0;
    _tableView.frame = CGRectMake(0,size.height,size.width,size.height - Y);
    
    [self.superview.superview addSubview:_tableView];
}

- (BOOL) interruptDecoder
{
    //if (!_decoder)
    //    return NO;
    return _interrupted;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return KxMovieInfoSectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
//        case KxMovieInfoSectionGeneral:
//            return NSLocalizedString(@"General", nil);
//        case KxMovieInfoSectionMetadata:
//            return NSLocalizedString(@"Metadata", nil);
//        case KxMovieInfoSectionVideo: {
//            NSArray *a = _decoder.info[@"video"];
//            return a.count ? NSLocalizedString(@"Video", nil) : nil;
//        }
        case KxMovieInfoSectionAudio: {
            NSArray *a = _decoder.info[@"audio"];
            return a.count ?  NSLocalizedString(@"Audio", nil) : nil;
        }
//        case KxMovieInfoSectionSubtitles: {
//            NSArray *a = _decoder.info[@"subtitles"];
//            return a.count ? NSLocalizedString(@"Subtitles", nil) : nil;
//        }
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
//        case KxMovieInfoSectionGeneral:
//            return KxMovieInfoGeneralCount;
//            
//        case KxMovieInfoSectionMetadata: {
//            NSDictionary *d = [_decoder.info valueForKey:@"metadata"];
//            return d.count;
//        }
//            
//        case KxMovieInfoSectionVideo: {
//            NSArray *a = _decoder.info[@"video"];
//            return a.count;
//        }
            
        case KxMovieInfoSectionAudio: {
            NSArray *a = _decoder.info[@"audio"];
            return a.count;
        }
            
//        case KxMovieInfoSectionSubtitles: {
//            NSArray *a = _decoder.info[@"subtitles"];
//            return a.count ? a.count + 1 : 0;
//        }
            
        default:
            return 0;
    }
}

- (id) mkCell: (NSString *) cellIdentifier
    withStyle: (UITableViewCellStyle) style
{
    UITableViewCell *cell = [self.audioAtrackTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.audioAtrackTable = tableView;
    UITableViewCell *cell;
    
    if (indexPath.section == KxMovieInfoSectionGeneral) {
        
        if (indexPath.row == KxMovieInfoGeneralBitrate) {
            
            int bitrate = [_decoder.info[@"bitrate"] intValue];
            cell = [self mkCell:@"ValueCell" withStyle:UITableViewCellStyleValue1];
            cell.textLabel.text = NSLocalizedString(@"Bitrate", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d kb/s",bitrate / 1000];
            
        } else if (indexPath.row == KxMovieInfoGeneralFormat) {
            
            NSString *format = _decoder.info[@"format"];
            cell = [self mkCell:@"ValueCell" withStyle:UITableViewCellStyleValue1];
            cell.textLabel.text = NSLocalizedString(@"Format", nil);
            cell.detailTextLabel.text = format ? format : @"-";
        }
        
    } else if (indexPath.section == KxMovieInfoSectionMetadata) {
        
        NSDictionary *d = _decoder.info[@"metadata"];
        NSString *key = d.allKeys[indexPath.row];
        cell = [self mkCell:@"ValueCell" withStyle:UITableViewCellStyleValue1];
        cell.textLabel.text = key.capitalizedString;
        cell.detailTextLabel.text = [d valueForKey:key];
        
    } else if (indexPath.section == KxMovieInfoSectionVideo) {
        
        NSArray *a = _decoder.info[@"video"];
        cell = [self mkCell:@"VideoCell" withStyle:UITableViewCellStyleValue1];
        cell.textLabel.text = a[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 2;
        
    } else if (indexPath.section == KxMovieInfoSectionAudio) {
        
//        NSArray *a = _decoder.info[@"audio"];
//        cell = [self mkCell:@"AudioCell" withStyle:UITableViewCellStyleValue1];
//        cell.textLabel.text = a[indexPath.row];
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        cell.textLabel.numberOfLines = 2;
//        BOOL selected = _decoder.selectedAudioStream == indexPath.row;
//        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
      //更新时间：2013-10-24
//        NSArray *a = _decoder.info[@"audio"];
//        //get audio track info
//        NSString *str = a[indexPath.row];
//        
//        cell = [self mkCell:@"AudioCell" withStyle:UITableViewCellStyleValue1];
//        
//        //display audiotrack name
//        cell.textLabel.text = [str substringToIndex:3];
//        
//        cell.textLabel.font = [UIFont systemFontOfSize:14];
//        cell.textLabel.numberOfLines = 2;
//        BOOL selected = _decoder.selectedAudioStream == indexPath.row;
//        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        //更新时间2013-12-3
        NSArray *a = _decoder.info[@"audio"];
        //get audio track info
        NSString *str = a[indexPath.row];
        
        cell = [self mkCell:@"AudioCell" withStyle:UITableViewCellStyleValue1];
        
        //display audiotrack name
        cell.textLabel.text = [str substringToIndex:3];
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 2;
        BOOL selected = _decoder.selectedAudioStream == indexPath.row;
        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    } else if (indexPath.section == KxMovieInfoSectionSubtitles) {
        
        NSArray *a = _decoder.info[@"subtitles"];
        
        cell = [self mkCell:@"SubtitleCell" withStyle:UITableViewCellStyleValue1];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 1;
        
        if (indexPath.row) {
            cell.textLabel.text = a[indexPath.row - 1];
        } else {
            cell.textLabel.text = NSLocalizedString(@"Disable", nil);
        }
        
        const BOOL selected = _decoder.selectedSubtitleStream == (indexPath.row - 1);
        cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == KxMovieInfoSectionAudio) {
        
        NSInteger selected = _decoder.selectedAudioStream;
        
        if (selected != indexPath.row) {
            
            _decoder.selectedAudioStream = indexPath.row;
            NSInteger now = _decoder.selectedAudioStream;
            
            if (now == indexPath.row) {
                
                UITableViewCell *cell;
                
                cell = [self.audioAtrackTable cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                indexPath = [NSIndexPath indexPathForRow:selected inSection:KxMovieInfoSectionAudio];
                cell = [self.audioAtrackTable cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [self.controllerDelegate dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
            else
            {
                
            }
        }
        
    } else if (indexPath.section == KxMovieInfoSectionSubtitles) {
        
        NSInteger selected = _decoder.selectedSubtitleStream;
        
        if (selected != (indexPath.row - 1)) {
            
            _decoder.selectedSubtitleStream = indexPath.row - 1;
            NSInteger now = _decoder.selectedSubtitleStream;
            
            if (now == (indexPath.row - 1)) {
                
                UITableViewCell *cell;
                
                cell = [self.audioAtrackTable cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                indexPath = [NSIndexPath indexPathForRow:selected + 1 inSection:KxMovieInfoSectionSubtitles];
                cell = [self.audioAtrackTable cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            // clear subtitles
            _subtitlesLabel.text = nil;
            _subtitlesLabel.hidden = YES;
            @synchronized(_subtitles) {
                [_subtitles removeAllObjects];
            }
        }
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        //初始化播放开启时，需要的东西
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //初始化播放开启时，需要的东西
    }
    return self;
}

#pragma mark 设置播放器位置

//设置播放器界面的长，度，位置
- (void)configScreenFrame:(CGRect)aFrame
{
    self.frame = aFrame;
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];
    CGRect playerFrame = aFrame;
    playerFrame.origin.x = 0;
    playerFrame.origin.y = 0;
    self.playerView.frame = playerFrame;
}

//双击全屏
- (void)fullScreen
{
    UIView *frameView = [self frameView];
    if (frameView.contentMode == UIViewContentModeScaleAspectFit)
    {
        frameView.contentMode = UIViewContentModeScaleAspectFill;
        isFullScreen = YES;
    }
    else
    {
        frameView.contentMode = UIViewContentModeScaleAspectFit;
        isFullScreen = NO;
    }
    //设置不让系统变黑屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

//- (void) setupPresentView
//{
//    //设置 播放器的界面
//    CGRect bounds = self.bounds;
//    KxMovieDecoder      *_decoder;
//    self.playerView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
//    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
//}

//界面加载
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    //设置 播放器的界面
//    [self setupPresentView];
//}
//
#pragma mark ----------------------播放控制

//根据 channelPath，进行播放，
//相当于    - (id) initWithContentPath: (NSString *) path
//parameters: (NSDictionary *) parameters
- (void)playVideo
{
    
//    加载网络视频时，需要告诉用户，已经加载 百分之几了，如20%
    [self.movieDelegate loading:@"20%" withPlay:self];
    [self play];
    //数据加载完成，准备播放时，通知用户，现在在播放了
   
    
    //播放过程中，如遇到错误，发起错识提醒，回调错识提醒代码,如网络断联
    [self.movieDelegate fail:NetworkDisconnetionType withPlay:self];
}

- (void)pauseVideo
{
    //暂停播放
    if (self.playing)
        [self pause];
    else
        [self play];
}

- (void)stopVideo
{
    //停止播放
    [self Disappear];
    [self.frameView removeFromSuperview];
}

#pragma mark ---------音轨

- (NSDictionary*)audioTracks
{
//    NSMutableArray *audioTrackValue = [NSMutableArray alloc];
    
//    //General
//    AudioTrack *trackGeneralBitrate = [[AudioTrack alloc] init];
//    int bitrate = [_decoder.info[@"bitrate"] intValue];
//    trackGeneralBitrate.title = NSLocalizedString(@"Bitrate", nil);
//    trackGeneralBitrate.desc = [NSString stringWithFormat:@"%d kb/s",bitrate / 1000];
//    trackGeneralBitrate.audioId = KxMovieInfoGeneralBitrate;
//    
//    AudioTrack *trackGeneralFormat = [[AudioTrack alloc] init];
//    NSString *format = _decoder.info[@"format"];
//    trackGeneralFormat.title = NSLocalizedString(@"Format", nil);
//    trackGeneralFormat.desc = format ? format : @"-";
//    trackGeneralFormat.audioId = KxMovieInfoGeneralFormat;
//    
//    AudioTrackSection *generalSection = [[AudioTrackSection alloc] init];
//    generalSection.type = KxMovieInfoSectionGeneral;
//    generalSection.sectionName =  NSLocalizedString(@"General", nil);
//    generalSection.audioTracks = @[trackGeneralBitrate,trackGeneralFormat];
//    [audioTrackValue addObject:generalSection];
//    
//    //Metadata
//    NSDictionary *metadataDic = [_decoder.info valueForKey:@"metadata"];
//    for (NSString *metadataKey in [metadataDic allKeys]) {
//        AudioTrack *trackMetadata = [[AudioTrack alloc] init];
//        trackMetadata.title = metadataKey;
//        trackGeneralBitrate.desc = [metadataDic valueForKey:metadataKey];
////        trackGeneralBitrate.audioId = KxMovieInfoGeneralBitrate;
//    }
//    
//    AudioTrack *trackGeneralBitrate = [[AudioTrack alloc] init];
//    int bitrate = [_decoder.info[@"bitrate"] intValue];
//    trackGeneralBitrate.title = NSLocalizedString(@"Bitrate", nil);
//    trackGeneralBitrate.desc = [NSString stringWithFormat:@"%d kb/s",bitrate / 1000];
//    trackGeneralBitrate.audioId = KxMovieInfoGeneralBitrate;
//    
//    AudioTrack *trackGeneralFormat = [[AudioTrack alloc] init];
//    NSString *format = _decoder.info[@"format"];
//    trackGeneralFormat.title = NSLocalizedString(@"Format", nil);
//    trackGeneralFormat.desc = format ? format : @"-";
//    trackGeneralFormat.audioId = KxMovieInfoGeneralFormat;
//    
//    AudioTrackSection *_AudioMetadata = [[AudioTrackSection alloc] init];
//    _AudioTrackSection.type = KxMovieInfoSectionGeneral;
//    _AudioTrackSection.sectionName =  NSLocalizedString(@"General", nil);
//    _AudioTrackSection.audioTracks = @[trackGeneralBitrate,_AudioTrackSection];
//    [audioTrackValue addObject:_AudioTrackSection];
//    
//    
//    NSString *metadataKey = NSLocalizedString(@"Metadata", nil);
//    NSString *videoKey = NSLocalizedString(@"Video", nil);
//    NSString *audioKey = NSLocalizedString(@"Audio", nil);
//    NSString *subtitles = NSLocalizedString(@"Subtitles", nil);
//    
//    
//    NSDictionary *metadataDic = [_decoder.info valueForKey:@"metadata"];
//    NSArray *videoTrackArray = _decoder.info[@"video"];
//    NSArray *audioTrackArray = _decoder.info[@"audio"];
//    NSArray *subtitlesTrackArray = _decoder.info[@"subtitles"];
//    
//    if (metadataDic) {
//        audioTrack[metadataKey] = metadataDic;
//    }
//    if (videoTrackArray.count>0) {
//        audioTrack[videoKey] = videoTrackArray;
//    }
//    if (audioTrackArray.count>0) {
//        audioTrack[audioKey] = audioTrackArray;
//    }
//    if (subtitlesTrackArray.count>0) {
//        audioTrack[subtitles] = subtitlesTrackArray;
//    }
    return nil;
}

-(void)audioTrack
{
    [self showInfoView: !_infoMode animated:YES];

}
//快起，或者是后退
//aPosition参数，是快进，或者后退秒数
//- (void)setPosition:(CGFloat)aPosition
//{
//    CGFloat position = _moviePosition + 10;
////    BOOL playMode = self.playing;
////    
////    self.playing = NO;
////    _disableUpdateHUD = YES;
////    [self enableAudio:NO];
////    
////    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
////    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
////        
////        [self updatePosition:position playMode:playMode];
////    });
//    
//}
- (void) forward
{
    [self setMoviePosition: _moviePosition + 10];
}

- (void) rewind
{
    [self setMoviePosition: _moviePosition - 10];
}

@end


