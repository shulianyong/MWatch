//
//  VCManager.h
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

static NSString *CurrentChannelName = @"CurrentChannelName";
@protocol VideoControllerDelegate <NSObject>

- (void)playChannel:(Channel*)aChannel;
- (void)stopChannel;

@end

@protocol ChannelRefreshIconDelegate<NSObject>

- (void)refreshIconWithChannelName:(NSString*)aName;

@end

@interface VCManager : UITableView<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate,ChannelRefreshIconDelegate>

- (void)deleteAllChannel;
- (void)refreshChannel;

@property (nonatomic,readonly) Channel* selectedChannel;
@property (nonatomic,readonly) Channel* preChannel;
@property (nonatomic,readonly) Channel* nextChannel;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,weak) id<VideoControllerDelegate> videoDelegate;

@end
