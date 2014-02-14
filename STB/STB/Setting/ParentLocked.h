//
//  ParentLocked.h
//  STB
//
//  Created by shulianyong on 13-10-16.
//  Copyright (c) 2013年 Shanghai Hanfir Enterprise Management Limited.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentLocked : UIViewController<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

@end


