//
//  RootViewController.h
//  WeatherMaps
//
//  Created by 俊紀 渡辺 on 11/08/29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
