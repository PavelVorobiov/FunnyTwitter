//
//  TweetTableViewCell.h
//  FunnyTwitter
//
//  Created by Pavel Vorobiov vpvpavel@gmail.com on 18.05.16.
//  Copyright © 2016 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *twitterName;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UIImageView *tweetMedia;
@property (weak, nonatomic) IBOutlet UIImageView *tweetOwnerImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetMediaHeight;

@end
