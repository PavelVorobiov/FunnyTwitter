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

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([[TwitterAccount sharedAccount] existAccount]) {
        [self dispatcher:@"" error:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 }

- (IBAction)pressTwitterLogin:(id)sender {
    [[TwitterAccount sharedAccount] loginWithCompletion:^(NSString *response, NSError *error) {
        [self dispatcher:response error:error];
    }];
}

- (void)dispatcher:(NSString *)response error:(NSError *)error {
    if ([response isEqualToString:@"accounts"]) {
        [self selectOneAccount:[[TwitterAccount sharedAccount] accounts]];
        
    } else {
        [self performSegueWithIdentifier:@"toApp" sender:nil];
    }

}

//- (void)errorHandler:(NSString *)message error:(NSError *)error {
//
//    // builds alert explanation message
//    NSMutableString *explanationMessage = [NSMutableString new];
//    if(message) {
//        [explanationMessage appendString:message];
//    }
//    if(error) {
//        if(explanationMessage.length>0) {
//            [explanationMessage appendString:@"\n"];
//        }
//        [explanationMessage appendString:error.localizedDescription];
//    }
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
//                                                                             message:explanationMessage
//                                                                      preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close"
//                                                          style:UIAlertActionStyleDefault
//                                                        handler:NULL];
//    
//    [alertController addAction:closeAction];
//    [self presentViewController:alertController animated:YES completion:NULL];
//}

- (void)selectOneAccount:(NSArray *)accounts {
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Доступны аккаунты"
                                                                         message:@"Выберите один из аккаунтов"
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                  handler:^(UIAlertAction * _Nonnull action) {
#warning !!!!
                                                  }]];
    for(NSString *_account in accounts) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:_account
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          
                                                          [[TwitterAccount sharedAccount] loginWithUsername:action.title
                                                                                                 completion:^(NSString *response, NSError *error) {
                                                                                                     [self dispatcher:response error:error];
                                                                                                 }];
                                                      }]];
    }
    [self presentViewController:actionSheet animated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
