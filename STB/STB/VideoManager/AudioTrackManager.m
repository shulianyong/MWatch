//
//  AudioTrackManager.m
//  STB
//
//  Created by shulianyong on 13-10-20.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "AudioTrackManager.h"
#import "AudioTrack.h"

@interface AudioTrackManager ()

@end

@implementation AudioTrackManager

- (id)initWithStyle:(UITableViewStyle)style withPlay:(STBPlayer*)aPlayer
{
    self = [super initWithStyle:style];
    if (self) {
        self.player = aPlayer;
        self.tableView.delegate = self.player;
        self.tableView.dataSource = self.player;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self.player;
    self.tableView.dataSource = self.player;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(click_backItem:)];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)click_backItem:(id)sender
{
    [self.player play];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL ret = NO;
    
    ret = (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation== UIDeviceOrientationLandscapeLeft);
    
    return ret;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.audioTracks allKeys].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.audioTracks allKeys] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self.audioTracks allKeys] objectAtIndex:section];
    NSArray *audioTrack = [self.audioTracks valueForKey:key];
    return audioTrack.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSString *key = [[self.audioTracks allKeys] objectAtIndex:indexPath.section];
    NSArray *audioTrackList = [self.audioTracks valueForKey:key];
    AudioTrack *track = [audioTrackList objectAtIndex:indexPath.row];
    cell.textLabel.text = track.title;
    cell.detailTextLabel.text = track.desc;
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
