//
//  LoginViewModel.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 21.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "FunnyTwitterLogic.h"
#import "TwitterAccount.h"

@interface LoginViewModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *successLogin;
@property (nonatomic, readonly) RACSignal *multipleAccount;
@property (nonatomic, readonly) RACSignal *loginWithUsername;


@property (strong, nonatomic) RACCommand *loginCommand;


@end
