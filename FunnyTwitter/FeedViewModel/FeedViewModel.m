//
//  FeedViewModel.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 19.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "FeedViewModel.h"
#import "Reachability.h"

@interface FeedViewModel ()

@property (nonatomic, strong) RACSignal *willChangeContentSignal;
@property (nonatomic, strong) RACSignal *itemChangeSignal;
@property (nonatomic, strong) RACSignal *sectionChangeSignal;
@property (nonatomic, strong) RACSignal *didChangeContentSignal;
@property (nonatomic, strong) RACSignal *closeFeedSignal;
@property (nonatomic, strong) RACSignal *sendTwitterPostSignal;

@end

@implementation FeedViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.active = YES;
    
    self.willChangeContentSignal = [[RACSubject subject] setNameWithFormat:@"FeedViewModel willChangeContentSignal"];
    self.itemChangeSignal = [[RACSubject subject] setNameWithFormat:@"FeedViewModel itemChangeSignal"];
    self.sectionChangeSignal = [[RACSubject subject] setNameWithFormat:@"FeedViewModel sectionChangeSignal"];
    self.didChangeContentSignal = [[RACSubject subject] setNameWithFormat:@"FeedViewModel didChangeContentSignal"];
    self.closeFeedSignal = [[RACSubject subject] setNameWithFormat:@"FeedViewModel closeFeedSignal"];
    
    @weakify(self)
    [self.didBecomeActiveSignal subscribeNext:^(id x) {
        @strongify(self);
        
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
    }];
    
    self.getTweetsCommand =
    [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
                                return [RACSignal empty];
    }];
    
    [self.getTweetsCommand.executionSignals
     subscribeNext:^(id x) {
         [[FunnyTwitterLogic sharedLogic] loadFeed];
     }];
    
    self.exitCommand =
    [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal empty];
    }];

    [self.exitCommand.executionSignals
     subscribeNext:^(id x) {
         if ([[FunnyTwitterLogic sharedLogic] deleteAccount:[TwitterAccount sharedAccount].currentAccount]) {
             [(id<RACSubscriber>)(self.closeFeedSignal) sendNext:nil];
         }
     }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(id x) {
         [[FunnyTwitterLogic sharedLogic] loadFeed];
     }];
    
    self.sendTwitterPostSignal = [RACSubject subject];
    
    [self.sendTwitterPostSignal
     subscribeNext:^(RACTuple *params) {
         RACTupleUnpack(NSString *tweetText) = params;
         [[FunnyTwitterLogic sharedLogic] addTweet:tweetText];
     }];
    
    self.addTweetCommand =
    [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal empty];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kReachabilityChangedNotification object:nil]
      takeUntil:[self rac_willDeallocSignal]]
     subscribeNext:^(NSNotification *notification) {
         Reachability *reachability = (Reachability *)notification.object;
         if (!reachability.isReachable) {
             [(id<RACSubscriber>)([AppDelegate sharedAppDelegate].errorSignal) sendNext:RACTuplePack(@"Отсутствует подключение к Internet")] ;
         } else {
             [[FunnyTwitterLogic sharedLogic] loadFeed];
         }
     }];

}

#pragma mark - Public Methods

- (NSString *)username {
    Account *account = [[TwitterAccount sharedAccount] currentAccount];
    ACAccount *ac = account.acaccount;
    return ac.username;
}

-(NSInteger)numberOfSections {
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (Tweet *)tweetAtIndexPath:(NSIndexPath *)indexPath {
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - NSFetchedResultsControllerDelegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [(id<RACSubscriber>)(self.willChangeContentSignal) sendNext:nil];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    [(id<RACSubscriber>)(self.itemChangeSignal) sendNext:RACTuplePack(indexPath, @(type), newIndexPath)];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    [(id<RACSubscriber>)(self.sectionChangeSignal) sendNext:RACTuplePack(@(sectionIndex), @(type))];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [(id<RACSubscriber>)(self.didChangeContentSignal) sendNext:nil];
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kEntityTweet
                                   inManagedObjectContext:moc];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
                                    initWithKey:@"created_at" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortByDate]];
    
    [fetchRequest setFetchBatchSize:20];
    Account *account = [[TwitterAccount sharedAccount] currentAccount];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"account == %@", account.objectID]];
    
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:moc
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
