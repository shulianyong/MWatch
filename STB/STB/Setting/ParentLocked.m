//
//  ParentLocked.m
//  STB
//
//  Created by shulianyong on 13-10-16.
//  Copyright (c) 2013年 Chengdu Sifang Information Technology Co.LTD. All rights reserved.
//

#import "ParentLocked.h"
#import "Channel.h"
#import "CommandClient.h"
#import "CommandResult.h"
#import "MBProgressHUD.h"

#import "../../../CommonUtil/CommonUtil/Categories/CategoriesUtil.h"

@interface ParentLocked ()<MBProgressHUDDelegate>
{
    MBProgressHUD *alertView;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (readonly,nonatomic) MBProgressHUD *alertView;

@end

@implementation ParentLocked

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self boundMultiLanWithView:self.view];
}


- (void)boundMultiLanWithView:(UIView*)supView
{
    for (UIView *sub in supView.subviews) {
        if (![sub isKindOfClass:[UIButton class]] && sub.subviews.count>0) {
            [self boundMultiLanWithView:sub];
        }
        else
        {
            if ([sub isKindOfClass:[UILabel class]]) {
                UILabel *lblKey = (UILabel*)sub;
                lblKey.text = MyLocalizedString(lblKey.text);
            }
            else if([sub isKindOfClass:[UIButton class]])
            {
                UIButton *btnKey = (UIButton*)sub;
                [btnKey setTitle:MyLocalizedString(btnKey.titleLabel.text) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------------提示信息
- (MBProgressHUD*)alertView
{
    if (alertView==nil) {
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        alertView = [[MBProgressHUD alloc] initWithWindow:window];
        [window addSubview:alertView];
        alertView.delegate = self;
        
    }
    return alertView;
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    alertView = nil;
}

//返回
- (IBAction)click_back:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    
    for (Channel *temp in _fetchedResultsController.fetchedObjects) {
        temp.tempSelected = [NSNumber numberWithBool:temp.lock.boolValue];
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
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
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Channel *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = object.name;
    
    UIImageView *imgSelected = nil;
    if (object.lock.boolValue) {
        imgSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_Selected.png"]];
    }
    else
    {
        imgSelected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_unselected.png"]];
    }
    imgSelected.frame = CGRectMake(0, 0, 25, 25);
    
    cell.accessoryView = imgSelected;
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

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = MyLocalizedString(@"Please select the channel needs to be locked");
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell==nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    }
    cell.imageView.image = [UIImage imageNamed:@"imgDefaultchannel.png"];
//    cell.textLabel.textColor = [UIColor whiteColor];
//    cell.textLabel.font = [UIFont systemFontOfSize:16];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

//选择某行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __block Channel *aChannel = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL lock = ![aChannel.lock boolValue];
    NSNumber *lockNumber = lock?@(1):@(0);
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [self configureCell:cell atIndexPath:indexPath];
    self.alertView.labelText = MyLocalizedString(@"Loading...");
    [self.alertView show:YES];
    
    [CommandClient commandParentLockWithChannels:@[aChannel.channelId] withLock:lockNumber withCallback:^(id info, HTTPAccessState isSuccess) {
        if (isSuccess==HTTPAccessStateSuccess) {
            self.alertView.labelText = MyLocalizedString(@"Completed");
            aChannel.lock = @(lock);
            NSError *error = nil;
            [[self.fetchedResultsController managedObjectContext] save:&error];
            //请求更新节目单事件
            [CommandClient postRefreshChannelEvent];
        }
        else
        {
            self.alertView.labelText = MyLocalizedString(@"Network Disconection");
        }
        [self.alertView hide:YES afterDelay:2];
    }];
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
