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

@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSMutableDictionary *securities;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:LoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:LogoutNotification object:nil];
    }
    return self;
}

- (NSArray *)favoriteUsers {
    return [self.users allValues];
}

- (NSArray *)favoriteSecurities {
    return [self.securities allValues];
}

-(BOOL)isFavorite:(NSString *)objectId {
    if (objectId && [self.users objectForKey:objectId] != nil) {
        return YES;
    }
    if (objectId && [self.securities objectForKey:objectId] != nil) {
        return YES;
    }
    return NO;
}

- (void)followUser:(PFUser *)user {
    [self.users setObject:user forKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    [[ParseClient instance] followUser:user];
}

- (void)unfollowUser:(PFUser *)user {
    [self.users removeObjectForKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    [[ParseClient instance] unfollowUser:user];
}

- (void)followSecurity:(Security *)security {
    if (security.objectId) {
        [self.securities setObject:security forKey:security.objectId];
        [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
        [[ParseClient instance] followSecurity:security];
    }
    else {
        [[ParseClient instance] createSecurityWithSymbol:security.symbol callback:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[ParseClient instance] fetchSecurityForSymbol:security.symbol callback:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        Security *security = [Security fromParseObjects:objects].firstObject;
                        [self.securities setObject:security forKey:security.objectId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
                        [[ParseClient instance] followSecurity:security];
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
}


- (void)unfollowSecurity:(Security *)security {
    [self.securities removeObjectForKey:security.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
    [[ParseClient instance] unfollowSecurity:security];
}

- (void)reload {
    [[ParseClient instance] fetchFavoriteUsers:^(NSArray *objects, NSError *error) {
        if (!error) {
            _users = [[NSMutableDictionary alloc] init];
            for (PFUser *user in objects) {
                [self.users setObject:user forKey:user.objectId];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [[ParseClient instance] fetchFavoriteSecurities:^(NSArray *objects, NSError *error) {
        if (!error) {
            _securities = [[NSMutableDictionary alloc] init];
            for (PFObject *object in objects) {
                Security *security = [[Security alloc] initWithData:object];
                [self.securities setObject:security forKey:security.objectId];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)clear {
    [self.users removeAllObjects];
    [self.securities removeAllObjects];
}

@end
