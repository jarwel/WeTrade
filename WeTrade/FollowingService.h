//
//  FollowingService.h
//  WeTrade
//
//  Created by Jason Wells on 2/14/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FollowingService : NSObject

+ (FollowingService *)instance;
- (NSArray *)asArray;
- (BOOL)contains:(NSString *)userId;
- (void)followUser:(PFUser *)user;
- (void)unfollowUser:(PFUser *)user;
- (void)loadFromServer;

@end
