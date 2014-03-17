//
//  FavoriteService.m
//  WeTrade
//
//  Created by Jason Wells on 2/14/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FavoriteService.h"
#import "Constants.h"
#import "ParseClient.h"

@interface FavoriteService ()

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *securities;
@property (nonatomic, strong) NSMutableSet *objectIds;

- (void)reload;
- (void)clear;

@end

@implementation FavoriteService

+ (FavoriteService *)instance {
    static FavoriteService *instance;
    if (!instance) {
        instance = [[FavoriteService alloc] init];
        [instance reload];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _users = [[NSMutableArray alloc] init];
        _securities = [[NSMutableArray alloc] init];
        _objectIds = [[NSMutableSet alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:LoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:LogoutNotification object:nil];
    }
    return self;
}

- (NSArray *)favoriteUsers {
    return self.users;
}

- (NSArray *)favoriteSecurities {
    return self.securities;
}

-(BOOL)isFavorite:(NSString *)objectId {
    if (objectId && [self.objectIds containsObject:objectId]) {
        return YES;
    }
    return NO;
}

- (void)followUser:(PFUser *)user {
    [self.users addObject:user];
    [self.objectIds addObject:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    [[ParseClient instance] followUser:user];
}

- (void)unfollowUser:(PFUser *)user {
    [self.users removeObject:user];
    [self.objectIds removeObject:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    [[ParseClient instance] unfollowUser:user];
}

- (void)followSecurity:(Security *)security {
    if (security.objectId) {
        [self.securities addObject:security];
        [self.objectIds addObject:security.objectId];
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
        [[ParseClient instance] followSecurity:security];
    }
    else {
        [[ParseClient instance] createSecurityWithSymbol:security.symbol callback:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[ParseClient instance] fetchSecurityForSymbol:security.symbol callback:^(Security *security) {
                    [self.securities addObject:security];
                    [self.objectIds addObject:security.objectId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
                    [[ParseClient instance] followSecurity:security];
                }];
            }
            else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}


- (void)unfollowSecurity:(Security *)security {
    if (security.objectId) {
        [self.securities removeObject:security];
        [self.objectIds removeObject:security.objectId];
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
        [[ParseClient instance] unfollowSecurity:security];
    }
}

- (void)reorderSecurities:(NSMutableArray *)securities {
    _securities = securities;
    [[ParseClient instance] updateFavoriteSecurities:securities];
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
}

- (void)reload {
    [[ParseClient instance] fetchFavoriteUsers:^(NSArray *users) {
        for (PFUser *user in users) {
            [self.users addObject:user];
            [self.objectIds addObject:user.objectId];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    }];
    [[ParseClient instance] fetchFavoriteSecurities:^(NSArray *securities) {
        for (Security *security in securities) {
            [self.securities addObject:security];
            [self.objectIds addObject:security.objectId];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    }];
}

- (void)clear {
    [self.users removeAllObjects];
    [self.securities removeAllObjects];
    [self.objectIds removeAllObjects];
}

@end
