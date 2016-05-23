//
//  TwitterAccount.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "TwitterAccount.h"
#import "FunnyTwitterLogic.h"

@implementation TwitterAccount {
    Account *_currentAccount;
    ACAccountStore *_accountStore;
}

+ (TwitterAccount *)sharedAccount {
    
    static dispatch_once_t pred;
    static TwitterAccount *_sharedAccount = nil;
    dispatch_once(&pred, ^{_sharedAccount = [[self alloc] init];
    });
    return _sharedAccount;
}


- (Account *)currentAccount {
    return _currentAccount;
}

- (void)setCurrentAccount:(ACAccount *)currentAccount {
    Account *savedAccount = [[FunnyTwitterLogic sharedLogic] savedAccount:currentAccount];
    if (!savedAccount) {
        _currentAccount = [[FunnyTwitterLogic sharedLogic] createNewAccount:currentAccount];;
        
    } else {
        _currentAccount = savedAccount;
    }
    [[FunnyTwitterLogic sharedLogic] loadFeed];
}

- (ACAccountStore *)accountStore {
    if(!_accountStore) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (BOOL)existAccount {
    
    ACAccountType *accountType = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSString *savedUsername = [[FunnyTwitterLogic sharedLogic] lastAccountUsername];
    if(!savedUsername) {
        return NO;
    }
    
    // check permission
    if(![accountType accessGranted]) {
        return NO;
    }
    
    NSArray *accounts = [[self accountStore] accountsWithAccountType:accountType];
    
    for(ACAccount *_account in accounts) {
        if([_account.username isEqualToString:savedUsername]) {
            self.currentAccount = _account;
            return YES;
        }
    }
    return NO;
}


- (void)loginWithCompletion:(void (^)(NSInteger accounts , NSError *error))completion {
    
    ACAccountType *accountType = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // create granted block
    void(^grantedBlock)() = ^() {
        NSArray *accounts = [[self accountStore] accountsWithAccountType:accountType];
        if(accounts.count == 0) {
            
            completion(0, nil);
            
        } else if(accounts.count==1) {
            [self setCurrentAccount:accounts.lastObject];
            completion(accounts.count, nil);
            
        } else {
            NSMutableArray *tempAc = [NSMutableArray new];
            for(ACAccount *account in accounts) {
                [tempAc addObject:account.username];
            }
            self.accounts = [NSArray arrayWithArray:tempAc];
            completion(accounts.count, nil);
        }
    };
    
    // ask for permission
    if(!accountType.accessGranted) {
        
        NSDictionary *options = nil;
        [[self accountStore] requestAccessToAccountsWithType:accountType
                                                     options:options
                                                  completion:^(BOOL granted, NSError *error) {
                                                      
                                                      if(granted) {
                                                          
                                                          dispatch_async(dispatch_get_main_queue(),^{
                                                              grantedBlock();
                                                          });
                                                          
                                                      } else {
                                                          [(id<RACSubscriber>)([AppDelegate sharedAppDelegate].errorSignal) sendNext:RACTuplePack(@"Отсутствует доступ к аккаунту twitter")] ;
                                                      }
                                                  }];
    } else {
        
        dispatch_async(dispatch_get_main_queue(),^{
            grantedBlock();
        });
    }
}

- (void)loginWithUsername:(NSString *)username completion:(void (^)( NSError *error))completion {
    
    ACAccountType *accountType = [[self accountStore] accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if(![accountType accessGranted]) {
        completion(nil);
        return;
    }
    
    NSArray *accounts = [[self accountStore] accountsWithAccountType:accountType];
    if(accounts.count==0) {
        completion(nil);
        return;
    }
    
    for(ACAccount *_account in accounts) {
        if([username isEqualToString:[_account username]]) {
            completion(nil);
            [self setCurrentAccount:_account];
            return;
        }
    }
    completion(nil);
}
@end
