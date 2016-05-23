//
//  LoginViewController.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import "LoginViewController.h"
#import "HTTPClient.h"
#import "TwitterAccount.h"
#import "LoginViewModel.h"

@interface LoginViewController ()

@property(nonatomic,retain) LoginViewModel *loginViewModel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginViewModel = [LoginViewModel new];
    
    self.loginButton.rac_command = self.loginViewModel.loginCommand;
    
    @weakify(self);
    [self.loginViewModel.multipleAccount subscribeNext:^(id _) {
        @strongify(self);
        [self selectOneAccount:[[TwitterAccount sharedAccount] accounts]];
    }];
    
    [self.loginViewModel.successLogin subscribeNext:^(id _) {
        @strongify(self);
        [self performSegueWithIdentifier:@"toApp" sender:nil];
    }];
    

}

- (void)viewDidAppear:(BOOL)animated {
    if ([[TwitterAccount sharedAccount] existAccount]) {
        [(id<RACSubscriber>)(self.loginViewModel.successLogin) sendNext:nil];
    }
}

- (void)selectOneAccount:(NSArray *)accounts {
    
    UIAlertController *actionSheet =
    [UIAlertController alertControllerWithTitle:@"Доступны аккаунты"
                                        message:@"Выберите один из аккаунтов"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
    for(NSString *_account in accounts) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:_account
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          
                                                          [(id<RACSubscriber>)
                                                           (self.loginViewModel.loginWithUsername) sendNext:RACTuplePack(action.title)];
                                                      }]];
    }
    [self presentViewController:actionSheet
                       animated:YES
                     completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
