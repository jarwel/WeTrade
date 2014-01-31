//
//  FollowUser.m
//  WeTrade
//
//  Created by Jason Wells on 1/28/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FollowUser.h"

@implementation FollowUser

- (NSString *)userId {
    return [self.data objectForKey:@"userId"];
}

- (NSString *)username {
    return [self.data objectForKey:@"username"];
}

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [users addObject:[[FollowUser alloc] initWithObject:object]];
    }
    return users;
}

@end
