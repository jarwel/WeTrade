//
//  ParseClient.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ParseClient.h"
#import <Parse/Parse.h>

@implementation ParseClient

+ (ParseClient *)instance {
    static ParseClient *instance;
    
    if (! instance) {
        instance = [[ParseClient alloc] init];
    }
    return instance;
}

- (void)fetchLotsForUser:(NSString *)user callback:(void (^)(NSArray *objects, NSError *error))callback {
    PFQuery *query = [PFQuery queryWithClassName:@"lot"];
    //[query whereKey:@"symbol" equalTo:@"F"];
    [query findObjectsInBackgroundWithBlock:callback];
}

- (void)createLotWithSymbol:(NSString *)symbol withPrice:(float) price withShares:(int)shares withCostBasis:(float)costBasis {
    NSLog([NSString stringWithFormat:@"createLot with symbol: %@ price: %f.00 shares: %d costBasis: %f.00", symbol, price, shares, costBasis]);
    
    PFObject *lotObject = [PFObject objectWithClassName:@"lot"];
    lotObject[@"symbol"] = symbol;
    lotObject[@"price"] = [@(price) stringValue];
    lotObject[@"shares"] = [@(shares) stringValue];
    lotObject[@"cost_basis"] = [@(costBasis) stringValue];
    [lotObject saveInBackground];
}

- (void)testParse {
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
}

@end
