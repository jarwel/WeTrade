//
//  ParseClient.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ParseClient.h"

@implementation ParseClient

+ (ParseClient *)instance {
    static ParseClient *instance;
    if (! instance) {
        instance = [[ParseClient alloc] init];
    }
    return instance;
}

- (void)fetchLots:(void (^)(NSArray *objects, NSError *error))callback {
    NSString *userId = [PFUser currentUser].objectId;
    [self fetchLotsForUserId:userId callback:callback];
}

- (void)fetchLotsForUserId:(NSString *)userId callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchLotsForUserId: %@", userId);
    PFQuery *query = [PFQuery queryWithClassName:@"Lot"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query whereKey:@"userId" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchCommentsForSymbol:(NSString *)symbol callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchCommentsForSymbol: %@", symbol);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"symbol" equalTo:symbol];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchFollowing:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchFollowing");
    
    PFRelation *relation = [[PFUser currentUser] relationforKey:@"following"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchUsersForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchUsersForSearch: %@", search);
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" hasPrefix:search];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)addCommentWithSymbol:(NSString *)symbol text:(NSString *)text {
    NSLog(@"addCommentWithSymbol: %@ text: %@", symbol, text);
    
    PFObject *commentObject = [PFObject objectWithClassName:@"Comment"];
    commentObject[@"symbol"] = symbol;
    commentObject[@"text"] = text;
    commentObject[@"user"] = [PFUser currentUser];
    [commentObject saveInBackground];
}

- (void)followUser:(PFUser *)user {
    NSLog(@"followUser: %@", user.objectId);

    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationforKey:@"following"];
    [relation addObject:user];
    [currentUser saveInBackground];
}

- (void)unfollowUser:(PFUser *)user {
    NSLog(@"unfollowUser: %@", user.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationforKey:@"following"];
    [relation removeObject:user];
    [currentUser saveInBackground];
}

- (void)updateLot:(Lot *)lot withCash:(NSString *)cash {
    PFObject *lotObject = lot.data;
    lotObject[@"cash"] = cash;
    [lotObject saveInBackground];
}

- (void)updateLots:(NSArray *)lots fromSource:(NSString *)source {
    NSLog(@"updateLots: %ld source: %@", lots.count, source);

    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Lot"];
    [query whereKey:@"userId" equalTo:currentUser.objectId];
    [query whereKey:@"source" equalTo:source];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (! error) {
            for (PFObject *object in objects) {
                [object deleteInBackground];
            }
            for (Lot *lot in lots) {
                NSString *userId = [PFUser currentUser].objectId;
                PFObject *lotObject = [PFObject objectWithClassName:@"Lot"];
                lotObject[@"userId"] = userId;
                lotObject[@"source"] = source;
                lotObject[@"symbol"] = lot.symbol;
                lotObject[@"shares"] = [@(lot.shares) stringValue];
                lotObject[@"costBasis"] = [@(lot.costBasis) stringValue];
                lotObject[@"cash"] = lot.cash ? lot.cash : @"No" ;
                [lotObject saveInBackground];
            }
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
