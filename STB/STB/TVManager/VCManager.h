//
//  VCManager.h
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"

@protocol VideoControllerDelegate <NSObject>

- (void)playChannel:(Channel*)aChannel;
- (void)stopChannel;

@end

@interface VCManager : UITableView<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>

- (void)deleteAllChannel;
- (void)refreshChannel;

@property (nonatomic,readonly) Channel* selectedChannel;
@property (nonatomic,readonly) Channel* preChannel;
@property (nonatomic,readonly) Channel* nextChannel;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic,weak) id<VideoControllerDelegate> videoDelegate;

@end
