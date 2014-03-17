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

- (void)fetchLots:(void (^)(NSArray *lots))callback {
    NSString *userId = [PFUser currentUser].objectId;
    [self fetchLotsForUserId:userId callback:callback];
}

- (void)fetchLotsForUserId:(NSString *)userId callback:(void (^)(NSArray *lots))callback {
    NSLog(@"fetchLotsForUserId: %@", userId);
    PFQuery *query = [PFQuery queryWithClassName:@"Lot"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query whereKey:@"userId" equalTo:userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *lots = [[NSMutableArray alloc] initWithCapacity:objects.count];
            for (PFObject *parseObject in objects) {
                [lots addObject:[[Lot alloc] initWithData:parseObject]];
            }
            callback(lots);
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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
    
    PFQuery *query = [PFUser query];
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

- (void)fetchFavoriteUsers:(void (^)(NSArray *users))callback {
    NSLog(@"fetchFavoriteUsers");
    
    PFUser *user = [PFUser currentUser];
    NSArray *objects = [user objectForKey:@"favoriteUsers"];
    [PFObject fetchAllIfNeededInBackground:objects block:^(NSArray *objects, NSError *error) {
        if (!error) {
            callback(objects);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)fetchFavoriteSecurities:(void (^)(NSArray *securities))callback {
    NSLog(@"fetchFavoriteSecurities");
    NSMutableArray *securities = [[NSMutableArray alloc] init];
    
    PFUser *user = [PFUser currentUser];
    NSArray *objects = [user objectForKey:@"favoriteSecurities"];
    [PFObject fetchAllIfNeededInBackground:objects block:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                [securities addObject:[[Security alloc] initWithData:object]];
            }
            callback(securities);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
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

- (void)createLots:(NSArray *)lots withSource:(NSString *)source callback:(void (^)(BOOL succeeded, NSError *error))callback {
    NSLog(@"createLots: %ld", lots.count);
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for (Lot *lot in lots) {
        PFObject *lotObject = [PFObject objectWithClassName:@"Lot"];
        lotObject[@"userId"] = [PFUser currentUser].objectId;
        lotObject[@"source"] = source;
        lotObject[@"symbol"] = lot.symbol;
        lotObject[@"shares"] = [@(lot.shares) stringValue];
        lotObject[@"costBasis"] = [@(lot.costBasis) stringValue];
        lotObject[@"cash"] = lot.cash ? lot.cash : @"No" ;
        [objects addObject:lotObject];
    }
    [PFObject saveAllInBackground:objects block:callback];
}

- (void)updateLot:(Lot *)lot withCash:(NSString *)cash {
    PFObject *lotObject = lot.data;
    lotObject[@"cash"] = cash;
    [lotObject saveInBackground];
}

- (void)updateFavoriteSecurities:(NSArray *)securities {
    NSLog(@"updateFavoriteSecurities: %ld", securities.count);
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for(Security *security in securities) {
        [objects addObject:security.data];
    }
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:objects forKey:@"favoriteSecurities"];
    [currentUser saveInBackground];
}

- (void)removeLots:(NSArray *)lots callback:(void (^)(BOOL succeeded, NSError *error))callback  {
    NSLog(@"removeLots: %ld", lots.count);
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    for(Lot *lot in lots) {
        [objects addObject:lot.data];
    }
    [PFObject deleteAllInBackground:objects block:callback];
}

- (void)followUser:(PFUser *)user {
    NSLog(@"followUser: %@", user.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addObject:user forKey:@"favoriteUsers"];
    [currentUser saveInBackground];
}

- (void)unfollowUser:(PFUser *)user {
    NSLog(@"unfollowUser: %@", user.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:user forKey:@"favoriteUsers"];
    [currentUser saveInBackground];
}

- (void)followSecurity:(Security *)security {
    NSLog(@"followSecurity: %@", security.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addObject:security.data forKey:@"favoriteSecurities"];
    [currentUser saveInBackground];
}

- (void)unfollowSecurity:(Security *)security {
    NSLog(@"unfollowSecurity: %@", security.objectId);
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:security.data forKey:@"favoriteSecurities"];
    [currentUser saveInBackground];
}


@end
