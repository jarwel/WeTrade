//
//  ParseClient.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Security.h"
#import "Lot.h"

@interface ParseClient : NSObject

+ (ParseClient *)instance;
- (void)fetchLots:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchLotsForUserId:(NSString *)userId callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchCommentsForSymbol:(NSString *)symbol callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchUsersForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchSecurityForSymbol:(NSString *)symbol callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchSecuritiesForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchFavoriteUsers:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchFavoriteSecurities:(void (^)(NSArray *objects, NSError *error))callback;
- (void)createCommentWithSymbol:(NSString *)symbol text:(NSString *) text;
- (void)createSecurityWithSymbol:(NSString *)symbol callback:(void (^)(BOOL succeeded, NSError *error))callback;
- (void)createLots:(NSArray *)lots withSource:(NSString *)source callback:(void (^)(BOOL succeeded, NSError *error))callback;
- (void)followUser:(PFUser *)user;
- (void)followSecurity:(Security *)security;
- (void)unfollowUser:(PFUser *)user;
- (void)unfollowSecurity:(Security *)security;
- (void)updateLot:(Lot *)lot withCash:(NSString *)cash;
- (void)removeLots:(NSArray *)lots callback:(void (^)(BOOL succeeded, NSError *error))callback;

@end
