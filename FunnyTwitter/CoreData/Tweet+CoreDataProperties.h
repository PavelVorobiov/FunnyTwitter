//
//  Tweet+CoreDataProperties.h
//  
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 20.05.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tweet.h"
#import "Media.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tweet (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *created;
@property (nullable, nonatomic, retain) NSString *idTweet;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *screen_name;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *profile_image_url_https;
@property (nullable, nonatomic, retain) NSDate *created_at;
@property (nullable, nonatomic, retain) Account *account;
@property (nullable, nonatomic, retain) NSSet<Media *> *media;

@end

@interface Tweet (CoreDataGeneratedAccessors)

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet<Media *> *)values;
- (void)removeMedia:(NSSet<Media *> *)values;

@end

NS_ASSUME_NONNULL_END
