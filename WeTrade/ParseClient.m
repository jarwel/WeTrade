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

- (void)fetchUserForUserId:(NSString *)userId callback:(void (^)(NSArray *objects, NSError *error))callback {
    NSLog(@"fetchUserForUserId: %@", userId);
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:userId];
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

- (void)followUserId:(NSString *)followUserId {
    NSLog(@"followUserId: %@", followUserId);

    NSString *userId = [PFUser currentUser].objectId;
    PFObject *lotObject = [PFObject objectWithClassName:@"followUser"];
    lotObject[@"userId"] = userId;
    lotObject[@"followUserId"] = followUserId;
    [lotObject saveInBackground];
}

@end
