//
//  AudioTrackManager.h
//  STB
//
//  Created by shulianyong on 13-10-20.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STBPlayer.h"
@interface AudioTrackManager : UITableViewController

@property (nonatomic,strong) NSDictionary *audioTracks;
@property (nonatomic,weak) STBPlayer *player;

- (id)initWithStyle:(UITableViewStyle)style withPlay:(STBPlayer*)aPlay;

@end
