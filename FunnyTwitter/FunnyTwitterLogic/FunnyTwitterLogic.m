//
//  FunnyTwitterLogic.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "FunnyTwitterLogic.h"

NSString *const kEntityAccount = @"Account";
NSString *const kEntityMedia = @"Media";
NSString *const kEntityTweet = @"Tweet";

@implementation FunnyTwitterLogic


+ (FunnyTwitterLogic *)sharedLogic {
    
    static dispatch_once_t pred;
    static FunnyTwitterLogic *_sharedLogic = nil;
    dispatch_once(&pred, ^{_sharedLogic = [[self alloc] init];
    });
    return _sharedLogic;
}

- (NSString *)lastAccountUsername {
    
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription
                             entityForName:kEntityAccount
                             inManagedObjectContext:moc]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc]
                                    initWithKey:@"created" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByDate]];
    
    NSError *error = nil;
    NSArray *entity = [moc executeFetchRequest:fetchRequest error:&error];
    
    Account *account = entity.lastObject;
    ACAccount *ac = account.acaccount;
    
    return ac.username;
}

- (Account *)createNewAccount:(ACAccount *)currentAccount {
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription
                             entityForName:kEntityAccount
                             inManagedObjectContext:moc]];
    [fetchRequest setIncludesPropertyValues:NO];

    NSError *deleteError = nil;
    NSArray *entity = [moc executeFetchRequest:fetchRequest error:&deleteError];
    for (NSManagedObject *each in entity) {
        [moc deleteObject:each];
    }
    
    Account *account = [NSEntityDescription insertNewObjectForEntityForName:kEntityAccount
                                                     inManagedObjectContext:moc];
    account.created = [NSDate date];
    account.acaccount = currentAccount;
    
    NSError *error;
    if (![moc save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return account;
}

- (Account *)savedAccount:(ACAccount *)account {
    
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription
                             entityForName:kEntityAccount
                             inManagedObjectContext:moc]];
    [fetchRequest setIncludesPropertyValues:NO]; 
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"acaccount == %@", account]];

    NSError *error = nil;
    NSArray *entity = [moc executeFetchRequest:fetchRequest error:&error];
    
    return entity.firstObject;
}

- (BOOL)deleteAccount:(Account *)account {
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription
                             entityForName:kEntityAccount
                             inManagedObjectContext:moc]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self == %@", account]];
    
    NSError *deleteError = nil;
    NSArray *entity = [moc executeFetchRequest:fetchRequest error:&deleteError];
    if (!entity.count) {
        return NO;
    }
    for (NSManagedObject *each in entity) {
        [moc deleteObject:each];
    }
    
    NSError *error;
    if (![moc save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    } else {
        return YES;
    }
    return NO;
}


- (void)loadFeed {
    [[HTTPClient sharedClient]feedWithCompletion:^(NSArray *tweets) {
        [self insertTweets:tweets];
    }];
}

- (void)addTweet:(NSString *)tweetText {
    [[HTTPClient sharedClient] sendTwitterPostText:tweetText
                                       withSuccess:^(NSDictionary *tweetDic) {
                                           [self insertTweets:[NSArray arrayWithObject:tweetDic]];
                                       }];
}

- (BOOL)existTweet:(NSString *)idTweet {
    
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription
                             entityForName:kEntityTweet
                             inManagedObjectContext:moc]];
    [fetchRequest setIncludesPropertyValues:NO];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"idTweet == %@",idTweet]];
    
    NSError *error = nil;
    NSInteger tweetCount = [moc countForFetchRequest:fetchRequest error:&error];
    return tweetCount?YES:NO;
}

- (NSDate *)formatingTweetDate:(NSString *)tweetDate {
    NSDateFormatter *dateFormatter= [NSDateFormatter new];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z yyyy"];
    
    NSDate *date = [dateFormatter dateFromString:tweetDate];

    return date;
}


- (void)insertTweets:(NSArray *)tweets {
    
    //without extended_entities
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];

    Account *currentAccount = [[TwitterAccount sharedAccount] currentAccount];
    
    [tweets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *tweetDic = obj;
        NSDictionary *user = tweetDic[@"user"];
        NSDictionary *entities = tweetDic[@"entities"];
        NSArray *media = entities[@"media"];
        
        if (![user[@"name"] isKindOfClass:[NSString class]] ||
            ![tweetDic[@"text"] isKindOfClass:[NSString class]] ||
            ![user[@"screen_name"] isKindOfClass:[NSString class]] ||
            ![user[@"profile_image_url_https"] isKindOfClass:[NSString class]] ||
            ![tweetDic[@"id"] isKindOfClass:[NSNumber class]] ||
            ![tweetDic[@"created_at"] isKindOfClass:[NSString class]]) {
            return;
        }
        
        if ([self existTweet:[NSString stringWithFormat:@"%@", tweetDic[@"id"]]]) {
            return;
        }
        
        Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:kEntityTweet
                                                     inManagedObjectContext:moc];
        tweet.created = [NSDate date];
        tweet.name = [user[@"name"] copy];
        tweet.screen_name = [user[@"screen_name"] copy];
        tweet.text = [tweetDic[@"text"] copy];
        tweet.idTweet = [NSString stringWithFormat:@"%@", tweetDic[@"id"]];
        tweet.profile_image_url_https = [user[@"profile_image_url_https"] copy];
        tweet.account = currentAccount;
        if ([self formatingTweetDate:tweetDic[@"created_at"]])
            tweet.created_at = [self formatingTweetDate:tweetDic[@"created_at"]];
        
        if ([media count]) {
            tweet.media = [self mediaForTweet:media];
        }
    }];
    
    NSError *error;
    if (![moc save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (NSSet *)mediaForTweet:(NSArray *)media {
    NSManagedObjectContext *moc = [[AppDelegate sharedAppDelegate] managedObjectContext];
    NSMutableArray *returnMedia = [NSMutableArray new];
    
    [media enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Media *media = [NSEntityDescription insertNewObjectForEntityForName:kEntityMedia
                                                     inManagedObjectContext:moc];

        if (![obj[@"id"] isKindOfClass:[NSNumber class]] ||
            ![obj[@"media_url_https"] isKindOfClass:[NSString class]]) {
            return;
        }
        media.created = [NSDate date];
        media.idMedia = [NSString stringWithFormat:@"%@", obj[@"id"]];
        media.media_url_https = [obj[@"media_url_https"] copy];
        
        [returnMedia addObject:media];
    }];

    return [NSSet setWithArray:returnMedia];
}



@end
