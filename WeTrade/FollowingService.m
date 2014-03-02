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

@property (nonatomic, strong) NSMutableDictionary *data;
- (void)synchronize;

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
    return [self.data allValues];
}

-(BOOL)contains:(NSString *)userId {
    return [self.data objectForKey:userId] != nil;
}

- (void)followUser:(PFUser *)user {
    [self.data setObject:user forKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] followUser:user];
}

- (void)unfollowUser:(PFUser *)user {
    [self.data removeObjectForKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] unfollowUser:user];
}

- (void)synchronize {
    [[ParseClient instance] fetchFollowing:^(NSArray *objects, NSError *error) {
        if (!error) {
            _data = [[NSMutableDictionary alloc] init];
            for (PFUser *user in objects) {
                [self.data setObject:user forKey:user.objectId];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
