//
//  FavoriteService.h
//  WeTrade
//
//  Created by Jason Wells on 2/14/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Security.h"

@interface FavoriteService : NSObject

@property (nonatomic, strong) NSArray *following;

+ (FavoriteService *)instance;
- (NSArray *)favoriteUsers;
- (NSArray *)favoriteSecurities;
- (void)followUser:(PFUser *)user;
- (void)unfollowUser:(PFUser *)user;
- (void)followSecurity:(Security *)security;
- (void)unfollowSecurity:(Security *)security;
- (BOOL)isFavorite:(NSString *)objectId;
- (void)synchronize;

@end
