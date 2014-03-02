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

@property (nonatomic, strong) NSArray *following;

+ (FollowingService *)instance;
- (BOOL)contains:(NSString *)userId;
- (void)followUser:(PFUser *)user;
- (void)unfollowUser:(PFUser *)user;
- (void)synchronize;

@end
