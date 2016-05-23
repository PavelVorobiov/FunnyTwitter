//
//  FeedTableViewController.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *exitButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTweetButton;

@end
