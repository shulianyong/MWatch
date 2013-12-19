//
//  MainViewController.m
//  kxmovie
//
//  Created by Kolyvan on 18.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "MainViewController.h"
//#import "KxMovieViewController.h"
 //for STB
#import "STBPlayer.h"
@interface MainViewController () {
    NSArray *_localMovies;
    NSArray *_remoteMovies;
    NSString *rtspUrl;
    STBPlayer *stbplayer;
}
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation MainViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Movies";
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag: 0];
        NSArray* docDirList=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* docDir=[docDirList objectAtIndex:0];
        NSString* countDir = [NSString stringWithFormat:@"%@/6ch_voices_id_7_dd_h264.ts",docDir];
        _remoteMovies = @[
//
//            @"http://eric.cast.ro/stream2.flv",
            @"http://liveipad.wasu.cn/cctv2_ipad/z.m3u8",                          
            @"http://www.wowza.com/_h264/BigBuckBunny_175k.mov",
            // @"http://www.wowza.com/_h264/BigBuckBunny_115k.mov",
            @"rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov"
//            @"http://santai.tv/vod/test/test_format_1.3gp",
//            @"http://santai.tv/vod/test/test_format_1.mp4",
//        
//            //@"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov",
//            //@"http://santai.tv/vod/test/BigBuckBunny_175k.mov",
//        
//            @"rtmp://aragontvlivefs.fplive.net/aragontvlive-live/stream_normal_abt",
//            @"rtmp://ucaster.eu:1935/live/_definst_/discoverylacajatv",
//            @"rtmp://edge01.fms.dutchview.nl/botr/bunny.flv"
        ];
        _localMovies = @[countDir];
        //for STB
        //初始化stbplayer
        stbplayer = [[STBPlayer alloc] init];
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 300) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    //for STB 
    UIButton* button = [[UIButton alloc] init];
    [button setFrame:CGRectMake(0, 250, 50, 50)];
	[button setBackgroundImage:[UIImage imageNamed:@"default_preview"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(pause)forControlEvents:UIControlEventTouchUpInside];
    UIButton* button1 = [[UIButton alloc] init];
    [button1 setFrame:CGRectMake(60, 250, 50, 50)];
	[button1 setBackgroundImage:[UIImage imageNamed:@"default_preview"] forState:UIControlStateNormal];
	[button1 addTarget:self action:@selector(forward)forControlEvents:UIControlEventTouchUpInside];
    UIButton* button2 = [[UIButton alloc] init];
    [button2 setFrame:CGRectMake(120, 250, 50, 50)];
	[button2 setBackgroundImage:[UIImage imageNamed:@"default_preview"] forState:UIControlStateNormal];
	[button2 addTarget:self action:@selector(rewind)forControlEvents:UIControlEventTouchUpInside];
    UIButton* button3 = [[UIButton alloc] init];
    [button3 setFrame:CGRectMake(180, 250, 50, 50)];
	[button3 setBackgroundImage:[UIImage imageNamed:@"default_preview"] forState:UIControlStateNormal];
	[button3 addTarget:self action:@selector(audioTrack)forControlEvents:UIControlEventTouchUpInside];
    //for STB
    //初始化，放置在你想放的地方
	[stbplayer configScreenFrame:CGRectMake(0, 0, 200, 150)];
    [stbplayer setBackgroundColor:[UIColor blackColor]];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:button];
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
     //for STB
    //for STB
    [self.view addSubview:stbplayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    //for STB
}
 //for STB
//播放控制：播放or暂停，快进，快退，音轨选择
- (void)pause{
        [stbplayer pauseorplay];
}
-(void)forward{
    [stbplayer forward];
}
-(void)rewind{
    [stbplayer rewind];
}
- (void)audioTrack{
    [stbplayer audioTrack];
}
//for STB

 //for STB
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		UITextField *input = [alertView textFieldAtIndex:0];
        rtspUrl = input.text;
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        // disable buffering
        parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
        parameters[KxMovieParameterMaxBufferedDuration] = @(0.0f);
        
        KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:rtspUrl
                                                                                   parameters:parameters];
        [self presentViewController:vc animated:YES completion:nil];

	}
}
//for STB

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadMovies];
    [self.tableView reloadData];
}
 //for STB
//程序进入后台暂停播放
- (void) applicationWillResignActive: (NSNotification *)notification
{
    [stbplayer pause];
    
    NSLog(@"applicationWillResignActive");
}
 //for STB


- (void) reloadMovies
{
    NSMutableArray *ma = [NSMutableArray array];
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES) lastObject];
    NSArray *contents = [fm contentsOfDirectoryAtPath:folder error:nil];
    
    for (NSString *filename in contents) {
        
        if (filename.length > 0 &&
            [filename characterAtIndex:0] != '.') {
            
            NSString *path = [folder stringByAppendingPathComponent:filename];
            NSDictionary *attr = [fm attributesOfItemAtPath:path error:nil];
            if (attr) {
                id fileType = [attr valueForKey:NSFileType];
                if ([fileType isEqual: NSFileTypeRegular] ||
                    [fileType isEqual: NSFileTypeSymbolicLink]) {
                    
                    NSString *ext = path.pathExtension.lowercaseString;
                    
                    if ([ext isEqualToString:@"mp3"] ||
                        [ext isEqualToString:@"caff"]||
                        [ext isEqualToString:@"aiff"]||
                        [ext isEqualToString:@"ogg"] ||
                        [ext isEqualToString:@"wma"] ||
                        [ext isEqualToString:@"m4a"] ||
                        [ext isEqualToString:@"m4v"] ||
                        [ext isEqualToString:@"wmv"] ||
                        [ext isEqualToString:@"3gp"] ||
                        [ext isEqualToString:@"mp4"] ||
                        [ext isEqualToString:@"mov"] ||
                        [ext isEqualToString:@"avi"] ||
                        [ext isEqualToString:@"mkv"] ||
                        [ext isEqualToString:@"mpeg"]||
                        [ext isEqualToString:@"mpg"] ||
                        [ext isEqualToString:@"flv"] ||
                        [ext isEqualToString:@"vob"]) {
                        
                        [ma addObject:path];
                    }
                }
            }
        }
    }
    
//    _localMovies = [ma copy];
    NSArray* docDirList=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docDir=[docDirList objectAtIndex:0];
    NSString* countDir = [NSString stringWithFormat:@"%@/6ch_voices_id_7_dd_h264.ts",docDir];
    NSString* countDir1 = [NSString stringWithFormat:@"%@/player.6",docDir];
    NSString* countDir2 = [NSString stringWithFormat:@"%@/player.7",docDir];
    NSString* countDir3 = [NSString stringWithFormat:@"%@/H264-AAC高误码信号断续.ts",docDir];
    NSString* countDir4 = [NSString stringWithFormat:@"%@/信号断断续续.ts",docDir];
    NSString* countDir5 = [NSString stringWithFormat:@"%@/0000_split.ts",docDir];
    NSString* countDir6 = [NSString stringWithFormat:@"%@/player.mosaic",docDir];
     NSString* countDir7 = [NSString stringWithFormat:@"%@/KeJiaoPingDao.ts",docDir];
     NSString* countDir8 = [NSString stringWithFormat:@"%@/player.nomosaic",docDir];
     NSString* countDir9 = [NSString stringWithFormat:@"%@/player.4",docDir];
    _localMovies = @[countDir,countDir1,countDir2,countDir3,countDir4,countDir5,countDir6,countDir7,countDir8,countDir9];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:     return @"R";
        case 1:     return @"L";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:     return _remoteMovies.count;
        case 1:     return _localMovies.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *path;
    
    if (indexPath.section == 0) {
        
        path = _remoteMovies[indexPath.row];
        
    } else {
        
        path = _localMovies[indexPath.row];
    }

    cell.textLabel.text = path.lastPathComponent;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (indexPath.section == 0) {
        
        path = _remoteMovies[indexPath.row];
        
    } else {
        
        path = _localMovies[indexPath.row];
    }
    
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([path.pathExtension isEqualToString:@"wmv"])
        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
            //for STB
        //首次播放或者切换频道
        if ([stbplayer playing]||[stbplayer paused]) {
            //为了切换，需要覆盖之前的子view
            STBPlayer *newplayer = [[STBPlayer alloc] init];
            [newplayer configScreenFrame:CGRectMake(0, 0, 200, 150)];
            [newplayer setBackgroundColor:[UIColor blackColor]];
            [self.view addSubview:newplayer];
            //停止之前的节目播放
            [stbplayer stopVideo];
            //获得新的view
            stbplayer = newplayer;
        }
            //播放当前指定节目
            [stbplayer initWithContentPath:path parameters:parameters];
         //for STB
}

- (void)fail:(_PlayerFailType)aFailType{}
- (void)loading:(NSString*)aPercent{}
- (void)loadend{}

@end
