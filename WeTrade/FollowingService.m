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

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation FollowingService

+ (FollowingService *)instance {
    static FollowingService *instance;
    if (!instance) {
        instance = [[FollowingService alloc] init];
        [instance loadFromServer];
    }
    return instance;
}

- (NSArray *)asArray {
    return [self.dictionary allValues];
}

-(BOOL)contains:(NSString *)userId {
    return [self.dictionary objectForKey:userId] != nil;
}

- (void)followUser:(PFUser *)user {
    [self.dictionary setObject:user forKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] followUser:user];
}

- (void)unfollowUser:(PFUser *)user {
    [self.dictionary removeObjectForKey:user.objectId];
    [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
    [[ParseClient instance] unfollowUser:user];
}

- (void)loadFromServer {
    [[ParseClient instance] fetchFollowing:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            for (PFUser *user in objects) {
                [dictionary setObject:user forKey:user.objectId];
            }
            _dictionary = dictionary;
            [[NSNotificationCenter defaultCenter] postNotificationName:FollowingChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
