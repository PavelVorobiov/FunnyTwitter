//
//  HTTPClient.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Accounts;
@import Social;


@interface HTTPClient : NSObject

+ (HTTPClient *)sharedClient;

- (void)feedWithCompletion:(void (^)(NSArray* jsonResponse))completion;

- (void)sendTwitterPostText:(NSString *)text
                withSuccess:(void (^)(NSDictionary* tweetDic))success;
@end
