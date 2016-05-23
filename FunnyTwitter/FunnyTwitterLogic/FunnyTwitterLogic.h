//
//  FunnyTwitterLogic.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "Tweet.h"
#import "Media.h"
#import "HTTPClient.h"
#import "TwitterAccount.h"

FOUNDATION_EXPORT NSString *const kEntityAccount;
FOUNDATION_EXPORT NSString *const kEntityTweet;

@interface FunnyTwitterLogic : NSObject

@property (strong,readonly) Account *currentAccount;

+ (FunnyTwitterLogic *)sharedLogic;
- (void)loadFeed;
- (NSString *)lastAccountUsername;
- (Account *)savedAccount:(ACAccount *)account;
- (Account *)createNewAccount:(ACAccount *)currentAccount;
- (BOOL)deleteAccount:(Account *)account;
- (void)addTweet:(NSString *)tweetText;

@end
