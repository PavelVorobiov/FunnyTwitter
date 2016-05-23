//
//  TwitterAccount.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import "FunnyTwitterLogic.h"

@interface TwitterAccount : NSObject

@property (strong,readonly) Account *currentAccount;
@property (strong,nonatomic) NSArray *accounts;


+ (TwitterAccount *)sharedAccount;

- (BOOL)existAccount;

- (void)loginWithCompletion:(void (^)(NSInteger accounts, NSError *error))completion;
- (void)loginWithUsername:(NSString *)username completion:(void (^)(NSError *error))completion;



@end
