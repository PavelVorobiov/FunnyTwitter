//
//  LoginViewModel.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 21.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "LoginViewModel.h"

@interface LoginViewModel ()

@property (nonatomic, strong) RACSignal *successLogin;
@property (nonatomic, strong) RACSignal *multipleAccount;
@property (nonatomic, strong) RACSignal *loginWithUsername;

@end

@implementation LoginViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.active = YES;
    
    self.successLogin = [[RACSubject subject] setNameWithFormat:@"LoginViewModel successLogin"];
    self.multipleAccount = [[RACSubject subject] setNameWithFormat:@"LoginViewModel multipleAccount"];
    
    self.loginCommand =
    [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal empty];
    }];
    
    [self.loginCommand.executionSignals
     subscribeNext:^(id x) {
         [[TwitterAccount sharedAccount] loginWithCompletion:^(NSInteger accounts, NSError *error) {
             if (accounts > 1) {
                 [(id<RACSubscriber>)(self.multipleAccount) sendNext:nil];
             } else {
                 [(id<RACSubscriber>)(self.successLogin) sendNext:nil];
             }
         }];
     }];

    self.loginWithUsername = [RACSubject subject];
    
    [self.loginWithUsername
     subscribeNext:^(RACTuple *params) {
         RACTupleUnpack(NSString *username) = params;
         [[TwitterAccount sharedAccount] loginWithUsername:username
                                                completion:^(NSError *error) {
                                                    [(id<RACSubscriber>)(self.successLogin) sendNext:nil];
                                                }];
     }];
}


@end
