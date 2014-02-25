//
//  Comment.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (PFUser *)user {
    if (!_user) {
        _user = [self.data objectForKey:@"user"];
    }
    return _user;
}

- (NSString *)username {
    if (!_username) {
        PFUser *user = [self user];
        return user.username;
    }
    return _username;
}

- (NSString *)text {
    if (!_text) {
        _text = [self.data objectForKey:@"text"];
    }
    return _text;
}

- (NSDate *)createdAt {
    if (!_createdAt) {
        _createdAt = self.data.createdAt;
    }
    return _createdAt;
}

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [comments addObject:[[Comment alloc] initWithData:object]];
    }
    return comments;
}

@end
