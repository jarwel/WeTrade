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
    
    PFQuery *query = [PFQuery queryWithClassName:@"lot"];
    [query whereKey:@"userId" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)fetchCommentsForSymbol:(NSString *)symbol callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchCommentsForSymbol: %@", symbol);
    
    PFQuery *query = [PFQuery queryWithClassName:@"comment"];
    [query whereKey:@"symbol" equalTo:symbol];
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
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)addLotWithSymbol:(NSString *)symbol price:(float) price shares:(int)shares costBasis:(float)costBasis {
    NSLog(@"createLotWithSymbol: %@ price: %f.00 shares: %d costBasis: %f.00", symbol, price, shares, costBasis);
    
    NSString *userId = [PFUser currentUser].objectId;
    PFObject *lotObject = [PFObject objectWithClassName:@"lot"];
    lotObject[@"userId"] = userId;
    lotObject[@"symbol"] = symbol;
    lotObject[@"price"] = [@(price) stringValue];
    lotObject[@"shares"] = [@(shares) stringValue];
    lotObject[@"costBasis"] = [@(costBasis) stringValue];
    [lotObject saveInBackground];
}

- (void)addCommentWithSymbol:(NSString *)symbol text:(NSString *)text {
    NSLog(@"addCommentWithSymbol: %@ text: %@", symbol, text);
    
    NSString *userId = [PFUser currentUser].objectId;
    PFObject *commentObject = [PFObject objectWithClassName:@"comment"];
    commentObject[@"symbol"] = symbol;
    commentObject[@"userId"] = userId;
    commentObject[@"text"] = text;
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

@end
