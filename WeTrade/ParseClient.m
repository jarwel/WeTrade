//
//  ParseClient.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ParseClient.h"
#import "PortfolioService.h"
#import "FavoriteService.h"
#import "Position.h"
#import "Lot.h"

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
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchUsersForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchUsersForSearch: %@", search);
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"canonicalUsername" hasPrefix:[search lowercaseString]];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchSecurityForSymbol:(NSString *)symbol callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchSecurityForSymbol: %@", symbol);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Security"];
    [query whereKey:@"symbol" equalTo:symbol];
    [query setLimit:1];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchSecuritiesForSearch:(NSString *)search callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchSecuritiesForSearch: %@", search);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Security"];
    [query whereKey:@"symbol" hasPrefix:[search uppercaseString]];
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchFavoriteUsers:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchFavoriteUsers");
    
    PFRelation *relation = [[PFUser currentUser] relationforKey:@"favoriteUsers"];
    PFQuery *query = [relation query];
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchFavoriteSecurities:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchFavoriteSecurities");
    
    PFRelation *relation = [[PFUser currentUser] relationforKey:@"favoriteSecurities"];
    PFQuery *query = [relation query];
    [query setLimit:100];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)createSecurityWithSymbol:(NSString *)symbol callback:(void (^)(BOOL succeeded, NSError *error))callback {
    NSLog(@"createSecurityWithSymbol: %@", symbol);
    
    PFObject *securityObject = [PFObject objectWithClassName:@"Security"];
    securityObject[@"symbol"] = symbol;
    [securityObject saveInBackgroundWithBlock:callback];
}

- (void)createCommentWithSymbol:(NSString *)symbol text:(NSString *)text {
    NSLog(@"createCommentWithSymbol: %@ text: %@", symbol, text);
    
    PFObject *commentObject = [PFObject objectWithClassName:@"Comment"];
    commentObject[@"symbol"] = symbol;
    commentObject[@"text"] = text;
    commentObject[@"user"] = [PFUser currentUser];
    [commentObject saveInBackground];
}

- (void)followUser:(PFUser *)user {
    NSLog(@"followUser: %@", user.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationforKey:@"favoriteUsers"];
    [relation addObject:user];
    [currentUser saveInBackground];
}

- (void)unfollowUser:(PFUser *)user {
    NSLog(@"unfollowUser: %@", user.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationforKey:@"favoriteUsers"];
    [relation removeObject:user];
    [currentUser saveInBackground];
}

- (void)followSecurity:(Security *)security {
    NSLog(@"followSecurity: %@", security.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationforKey:@"favoriteSecurities"];
    [relation addObject:security.data];
    [currentUser saveInBackground];
}

- (void)unfollowSecurity:(Security *)security {
    NSLog(@"unfollowSecurity: %@", security.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    PFRelation *relation = [currentUser relationforKey:@"favoriteSecurities"];
    [relation removeObject:security.data];
    [currentUser saveInBackground];
}

- (void)updateLot:(Lot *)lot withCash:(NSString *)cash {
    PFObject *lotObject = lot.data;
    lotObject[@"cash"] = cash;
    [lotObject saveInBackground];
}

- (void)updateLots:(NSArray *)lots fromSource:(NSString *)source {
    NSLog(@"updateLots: %ld source: %@", lots.count, source);

    NSMutableArray *saves = [[NSMutableArray alloc] init];
    for (Lot *lot in lots) {
        PFObject *lotObject = [PFObject objectWithClassName:@"Lot"];
        lotObject[@"userId"] = [PFUser currentUser].objectId;
        lotObject[@"source"] = source;
        lotObject[@"symbol"] = lot.symbol;
        lotObject[@"shares"] = [@(lot.shares) stringValue];
        lotObject[@"costBasis"] = [@(lot.costBasis) stringValue];
        lotObject[@"cash"] = lot.cash ? lot.cash : @"No" ;
        [saves addObject:lotObject];
    }
    
    NSMutableArray *deletes = [[NSMutableArray alloc] init];
    for (Position *position in [[PortfolioService instance] positions]) {
        for(Lot *lot in position.lots) {
            if ([lot.source isEqualToString:source]) {
                [deletes addObject:lot.data];
            }
        }
    }
    
    [PFObject deleteAllInBackground:deletes block:^(BOOL succeeded, NSError *error) {
        if (!error){
            [PFObject saveAllInBackground:saves block:^(BOOL succeeded, NSError *error) {
                if (!error){
                    [[PortfolioService instance] synchronize];
                }
                else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
