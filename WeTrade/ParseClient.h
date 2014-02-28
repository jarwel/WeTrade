//
//  ParseClient.h
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ParseClient : NSObject

+ (ParseClient *)instance;
- (void)fetchLots:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchLotsForUserId:(NSString *)userId callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchCommentsForSymbol:(NSString *)symbol callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchFollowing:(void (^)(NSArray *objects, NSError *error))callback;
- (void)fetchUsersForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback;
- (void)addCommentWithSymbol:(NSString *)symbol text:(NSString *) text;
- (void)updateLots:(NSArray *)lots fromSource:(NSString *)source;
- (void)followUser:(PFUser *)user;
- (void)unfollowUser:(PFUser *)user;

@end
