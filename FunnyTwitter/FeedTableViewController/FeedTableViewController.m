//
//  FeedTableViewController.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "FeedTableViewController.h"
#import "FeedViewModel.h"

#import "TwitterAccount.h"
#import "HTTPClient.h"
#import "TweetTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "FunnyTwitterLogic.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface FeedTableViewController ()

@property (strong, atomic) NSArray *tweets;
@property(nonatomic,retain) FeedViewModel *viewModel;

@end

@implementation FeedTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewModel = [FeedViewModel new];
    
    self.navigationItem.title = [self.viewModel username];
    
    @weakify(self);
    [self.viewModel.willChangeContentSignal subscribeNext:^(id _) {
        @strongify(self);
        [self.tableView beginUpdates];
    }];
    
    [self.viewModel.itemChangeSignal subscribeNext:^(RACTuple *params) {
        @strongify(self);
        RACTupleUnpack(NSIndexPath *indexPath, NSNumber *typeNumber, NSIndexPath *newIndexPath) = params;
        NSFetchedResultsChangeType type = typeNumber.unsignedIntegerValue;
        
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
                [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
                break;
        }
    }];
    
    [self.viewModel.sectionChangeSignal subscribeNext:^(RACTuple *params) {
        @strongify(self);
        
        RACTupleUnpack(NSNumber *sectionIndexNumber, NSNumber *typeNumer) = params;
        NSUInteger sectionIndex = sectionIndexNumber.unsignedIntegerValue;
        NSUInteger type = typeNumer.unsignedIntegerValue;
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }];
    
    [self.viewModel.didChangeContentSignal subscribeNext:^(id _) {
        @strongify(self);
        [self.tableView endUpdates];
    }];
    self.tableView.estimatedRowHeight = 50.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    self.refreshControl.rac_command = self.viewModel.getTweetsCommand;
    self.addTweetButton.rac_command = self.viewModel.addTweetCommand;
    self.exitButton.rac_command = self.viewModel.exitCommand;
  
    [self.viewModel.closeFeedSignal subscribeNext:^(id _) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self.viewModel.addTweetCommand.executionSignals
     subscribeNext:^(id x) {
         @strongify(self);
         [self addTweet];
     }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Tweet *tweet = [self.viewModel tweetAtIndexPath:indexPath];
    
    cell.accountName.text = tweet.name;
    cell.tweetText.text = tweet.text;
    cell.twitterName.text = [NSString stringWithFormat:@"@%@", tweet.screen_name];
    [cell.tweetOwnerImage sd_setImageWithURL:[NSURL URLWithString:tweet.profile_image_url_https]];

    if (![tweet.media count]) {
        cell.tweetMedia.image = nil;
        cell.tweetMediaHeight.constant = 0;

    } else {
        cell.tweetMediaHeight.constant = 130;
        [tweet.media enumerateObjectsUsingBlock:^(Media * _Nonnull obj, BOOL * _Nonnull stop) {
            [cell.tweetMedia sd_setImageWithURL:[NSURL URLWithString:obj.media_url_https]];
            *stop = YES;
            return;
        }];
    }
    
    return cell;
}

- (void)addTweet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New tweet"
                                                                             message:@"Sometimes things get ugly but functional!"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"To tweet"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                       [(id<RACSubscriber>)
                                        (self.viewModel.sendTwitterPostSignal) sendNext:RACTuplePack(alertController.textFields.firstObject.text)];
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        
    }];
    
    [alertController.view setNeedsLayout ];
    
    [self presentViewController:alertController animated:YES completion:NULL];
}

@end
