//
//  HTTPClient.m
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#define baseURLString                       @"https://api.twitter.com/1.1/"

#import "HTTPClient.h"
#import "TwitterAccount.h"


@implementation HTTPClient

+ (HTTPClient *)sharedClient {
    
    static dispatch_once_t pred;
    static HTTPClient *_sharedClient = nil;
    dispatch_once(&pred, ^{_sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (void)feedWithCompletion:(void (^)(NSArray* jsonResponse))completion {
    
    NSDictionary* params = @{@"count" : @"50"};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:[NSString stringWithFormat:@"%@statuses/home_timeline.json", baseURLString]]
                                               parameters:params];
    
    request.account = [[TwitterAccount sharedAccount] currentAccount].acaccount;
    
    [request performRequestWithHandler:^(NSData *responseData,
                                         NSHTTPURLResponse *urlResponse, NSError *error) {
    
        if (error)
        {
            [(id<RACSubscriber>)([AppDelegate sharedAppDelegate].errorSignal) sendNext:RACTuplePack(@"Ошибка получения ленты")] ;
        }
        else
        {
            NSError *jsonError;
            NSArray *responseJSON = [NSJSONSerialization
                                     JSONObjectWithData:responseData
                                     options:NSJSONReadingAllowFragments
                                     error:&jsonError];
            
            if(completion){
                completion(responseJSON);
            }
        }
    }];
}

- (void)sendTwitterPostText:(NSString *)text
                withSuccess:(void (^)(NSDictionary* tweetDic))success {
    
    NSString *postString = text;
    NSDictionary *postParams = @{
                                 @"status":postString
                                 };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:[NSURL URLWithString:[NSString stringWithFormat:@"%@statuses/update.json", baseURLString]]
                                               parameters:postParams];
    request.account = [[TwitterAccount sharedAccount] currentAccount].acaccount;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(error) {
            [(id<RACSubscriber>)([AppDelegate sharedAppDelegate].errorSignal) sendNext:RACTuplePack(@"Не удалось отправить tweet")] ;
        } else {
            NSError *error = nil;
            NSDictionary *tweetDic = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            success(tweetDic);
        }
    }];
    
}
@end
