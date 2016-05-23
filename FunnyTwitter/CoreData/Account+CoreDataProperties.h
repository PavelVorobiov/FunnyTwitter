//
//  Account+CoreDataProperties.h
//  
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 19.05.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *created;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) id acaccount;
@property (nullable, nonatomic, retain) NSSet<Tweet *> *tweets;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet<Tweet *> *)values;
- (void)removeTweets:(NSSet<Tweet *> *)values;

@end

NS_ASSUME_NONNULL_END
