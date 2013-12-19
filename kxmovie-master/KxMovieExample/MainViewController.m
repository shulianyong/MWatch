//
//  MainViewController.m
//  kxmovie
//
//  Created by pk 21.05.13.
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt
#import "MainViewController.h"
#import "KxMovieViewController.h"

@interface MainViewController () {
    NSArray *_localMovies;
    NSArray *_remoteMovies;
    NSString *rtspUrl;
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
            @"http://liveipad.wasu.cn/cctv5_ipad/z.m3u8",                          
            @"http://www.wowza.com/_h264/BigBuckBunny_175k.mov",
            // @"http://www.wowza.com/_h264/BigBuckBunny_115k.mov",
            @"rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov",
            @"http://santai.tv/vod/test/test_format_1.3gp",
            @"http://santai.tv/vod/test/test_format_1.mp4",
        
            //@"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov",
            //@"http://santai.tv/vod/test/BigBuckBunny_175k.mov",
        
            @"rtmp://aragontvlivefs.fplive.net/aragontvlive-live/stream_normal_abt",
            @"rtmp://ucaster.eu:1935/live/_definst_/discoverylacajatv",
            @"rtmp://edge01.fms.dutchview.nl/botr/bunny.flv"
        ];
        _localMovies = @[countDir];
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
    UIButton* button = [[UIButton alloc] init];
    [button setFrame:CGRectMake(110, 250, 100, 100)];
	[button setBackgroundImage:[UIImage imageNamed:@"default_preview"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(swapCamera)forControlEvents:UIControlEventTouchUpInside];
	
    [self.view addSubview:self.tableView];
//    [self.view addSubview:button];
}
- (void)swapCamera{
            UIAlertView *qqAlert = [[UIAlertView alloc] initWithTitle:@"RTSP" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好", nil];
            [qqAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [qqAlert show];
}
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
    static int index = 10;
    index++;
    path = @"http://192.168.0.1:8085/player.%d";
    path = [NSString stringWithFormat:path,index];
    path = @"http://192.168.0.1:8085/player.2";
    // disable buffering
    //parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
    //parameters[KxMovieParameterMaxBufferedDuration] = @(0.0f);
    NSLog(path);
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
                                                                               parameters:parameters];
    [self presentViewController:vc animated:YES completion:nil];
    //[self.navigationController pushViewController:vc animated:YES];    
}

@end
