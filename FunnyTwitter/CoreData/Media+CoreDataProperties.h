//
//  Media+CoreDataProperties.h
//  
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 19.05.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Media.h"

NS_ASSUME_NONNULL_BEGIN

@interface Media (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *created;
@property (nullable, nonatomic, retain) NSString *idMedia;
@property (nullable, nonatomic, retain) NSString *media_url_https;
@property (nullable, nonatomic, retain) Tweet *tweet;

@end

NS_ASSUME_NONNULL_END
