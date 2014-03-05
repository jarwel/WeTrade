//
//  FollowingService.m
//  WeTrade
//
//  Created by Jason Wells on 2/14/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowingService.h"
#import "Constants.h"
#import "ParseClient.h"

@interface FollowingService ()

@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSMutableDictionary *securities;

@end

@implementation FollowingService

+ (FollowingService *)instance {
    static FollowingService *instance;
    if (!instance) {
        instance = [[FollowingService alloc] init];
        [instance synchronize];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synchronize) name:LoginNotification object:nil];
    }
    return self;
}

- (NSArray *)following {
    return [self.users allValues];
}

- (NSArray *)watching {
    return [self.securities allValues];
}

- (void)followUser:(PFUser *)user {
    [self.users setObject:user forKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] followUser:user];
}

- (void)unfollowUser:(PFUser *)user {
    [self.users removeObjectForKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] unfollowUser:user];
}

- (void)followSecurity:(Security *)security {
    if (security.objectId) {
        [self.securities setObject:security forKey:security.objectId];
        [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
        [[ParseClient instance] followSecurity:security];
    }
    else {
        [[ParseClient instance] createSecurityWithSymbol:security.symbol callback:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[ParseClient instance] fetchSecurityForSymbol:security.symbol callback:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        Security *security = [Security fromParseObjects:objects].firstObject;
                        [self.securities setObject:security forKey:security.objectId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] unfollowSecurity:security];
}

-(BOOL)isFollowingObjectId:(NSString *)objectId {
    if (objectId && [self.users objectForKey:objectId] != nil) {
        return YES;
    }
    if (objectId && [self.securities objectForKey:objectId] != nil) {
        return YES;
    }
    return NO;
}

- (void)synchronize {
    [[ParseClient instance] fetchFollowing:^(NSArray *objects, NSError *error) {
        if (!error) {
            _users = [[NSMutableDictionary alloc] init];
            for (PFUser *user in objects) {
                [self.users setObject:user forKey:user.objectId];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [[ParseClient instance] fetchWatching:^(NSArray *objects, NSError *error) {
        if (!error) {
            _securities = [[NSMutableDictionary alloc] init];
            for (PFObject *object in objects) {
                Security *security = [[Security alloc] initWithData:object];
                [self.securities setObject:security forKey:security.objectId];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
