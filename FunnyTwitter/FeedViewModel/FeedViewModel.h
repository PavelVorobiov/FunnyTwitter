//
//  FeedViewModel.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 19.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FunnyTwitterLogic.h"
#import "TwitterAccount.h"


@interface FeedViewModel : RVMViewModel <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) RACSignal *willChangeContentSignal;
@property (nonatomic, readonly) RACSignal *itemChangeSignal;
@property (nonatomic, readonly) RACSignal *sectionChangeSignal;
@property (nonatomic, readonly) RACSignal *didChangeContentSignal;
@property (nonatomic, readonly) RACSignal *closeFeedSignal;
@property (nonatomic, readonly) RACSignal *sendTwitterPostSignal;


@property (strong, nonatomic) RACCommand *exitCommand;
@property (strong, nonatomic) RACCommand *getTweetsCommand;
@property (strong, nonatomic) RACCommand *addTweetCommand;


@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (readonly, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSString *)username;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (Tweet *)tweetAtIndexPath:(NSIndexPath *)indexPath;


@end
