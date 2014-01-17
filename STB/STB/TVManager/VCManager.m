//
//  VCManager.m
//  STB
//
//  Created by shulianyong on 13-9-28.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "VCManager.h"
#import "DataManager.h"
#import "CommonUtil.h"
#import "CommandResult.h"
#import "ChannelCell.h"

#import "CommandClient.h"
#import "../../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"
#import "DefaultChannelTool.h"

#import "AFNetworkReachabilityManager.h"

@interface VCManager ()

@end

@implementation VCManager

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        
//        [self deleteAllChannel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    static BOOL isFirstLoad = YES;
    if (isFirstLoad) {
        UIImage *imgBGChannel = [UIImage imageNamed:@"imgBGChannel"];
        UIImageView *imgvBG = [[UIImageView alloc] initWithImage:imgBGChannel];
        self.backgroundView =  imgvBG;
        isFirstLoad = NO;
    }
    
}

#pragma mark ----------------------- core data

- (NSManagedObjectContext*)managedObjectContext
{
    return [DataManager shareInstance].managedObjectContext;
}

#pragma mark - Fetched results controller


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Channel *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImage *imgChannel = [UIImage imageNamed:object.name];
    if (!imgChannel) {
        imgChannel = [UIImage imageNamed:@"imgDefaultchannel.png"];
    }
    
    cell.imageView.image = imgChannel;
    cell.textLabel.text = object.name;
    [(ChannelCell*)cell setIsLock:object.lock.boolValue];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIView *selectedBG = [[UIView alloc] init];
    selectedBG.backgroundColor = RGBColor(6, 30, 36);
    cell.selectedBackgroundView = selectedBG;
    [self configureCell:cell atIndexPath:indexPath];    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Channel *aChannel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([aChannel.name isEqualToString:[DefaultChannelTool shareInstance].defaultChannelName]
        && aChannel.channelId.integerValue==[DefaultChannelTool shareInstance].defaultChannelId)
    {
        return;
    }
    [self.videoDelegate playChannel:aChannel];
}

#pragma mark-------------------------------
#pragma mark-------------------------------刷新

- (void)deleteAllChannel
{
    // Save the context.
    NSError *error = nil;
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    for (Channel *newManagedObject in self.fetchedResultsController.fetchedObjects) {
        [context deleteObject:newManagedObject];
    }
    if(![context save:&error])
    {
        ERROR(@"删除之前的节目单失败:error-> %@,userInfo-> %@", error, [error userInfo]);
    }
}

- (void)insertNewObjects:(NSArray*)channels
{
    
    [self deleteAllChannel];
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    //保存新刷的列表
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    for (NSDictionary *dicObject in channels) {
        Channel *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [newManagedObject reflectDataFromOtherObject:dicObject];
        newManagedObject.timeStamp = [NSDate date];
    }
    
    NSError *error = nil;
    if (![context save:&error]) {
        ERROR(@"保存新刷的列表失败:error-> %@,userInfo-> %@", error, [error userInfo]);
        abort();
    }
    
    
    //播放节目
    if (channels.count>0)
    {
        [self playChannel:self.selectedChannel];
    }
    else
    {
        [self.videoDelegate stopChannel];
    }
    
    if (channels.count>0) {
        Channel *selectedChannel = [self selectedChannel];
        NSIndexPath *indexPath  = nil;
        if (selectedChannel) {
            indexPath = [self.fetchedResultsController indexPathForObject:selectedChannel];
            if (indexPath.row==0) {
                 indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
        [self performSelector:@selector(selectedCell:) withObject:indexPath afterDelay:1];
    }
}


- (void)refreshChannel
{
    __weak VCManager *weakSelf = self;
    [CommandClient commandChannelListWithCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess)
        {
            CommandResult *result = [[CommandResult alloc] init];
            [result reflectDataFromOtherObject:info];
            
            NSArray *channels = [(NSDictionary*)info objectForKey:@"channel"];
            if (channels.count==0) {
                [CommonUtil showMessage:MyLocalizedString(@"Channel List is empty")];
            }
            else
            {
                [weakSelf insertNewObjects:channels];
            }
        }
        else
        {
            [CommonUtil showMessage:MyLocalizedString(@"Error:Channel List Command")];
        }
    }];
}

#pragma mark------------------------------- 需要选择的table cell
- (void)selectedCell:(NSIndexPath*)indexPath
{
    [self selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}


#pragma mark-------------------------------
#pragma mark------------------------------- 应该播放的节目


- (Channel*)selectedChannel
{
    Channel *selectedChannel = nil;
    if(self.fetchedResultsController.fetchedObjects.count>0)
    {
        if ([DefaultChannelTool shareInstance].defaultChannelId>0)
        {
            for (Channel *aChannel in self.fetchedResultsController.fetchedObjects)
            {
                if (aChannel.channelId.integerValue == [DefaultChannelTool shareInstance].defaultChannelId)
                {
                    selectedChannel = aChannel;
                    break;
                }
            }
        }
        
        if (selectedChannel==nil && ![NSString isEmpty:[DefaultChannelTool shareInstance].defaultChannelName])
        {
            for (Channel *aChannel in self.fetchedResultsController.fetchedObjects)
            {
                if ([aChannel.name isEqualToString:[DefaultChannelTool shareInstance].defaultChannelName])
                {
                    selectedChannel = aChannel;
                    break;
                }
            }
        }
        
        if (selectedChannel==nil)
        {
            selectedChannel = self.fetchedResultsController.fetchedObjects.firstObject;
        }
    }
    return selectedChannel;
}

#pragma mark ---------上一节目
- (Channel*)preChannel
{
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    if (count==0) {
        return nil;
    }
    
    Channel *preChannel = nil;
    NSInteger index = [self.fetchedResultsController indexPathForObject:self.selectedChannel].row;
    if (index==0) {
        index = count-1;
    }
    else {
        index--;
    }
    preChannel = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    return preChannel;
}
#pragma mark ---------下一节目
- (Channel*)nextChannel
{
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    if (count==0) {
        return nil;
    }
    
    Channel *nextChannel = nil;
    NSInteger index = [self.fetchedResultsController indexPathForObject:self.selectedChannel].row;
    if (index==count-1) {
        index = 0;
    }
    else{
        index++;
    }
    nextChannel = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    return nextChannel;
}

#pragma mark -----------播放
- (void)playChannel:(Channel*)aChannel
{
    [self.videoDelegate playChannel:aChannel];
}


@end
