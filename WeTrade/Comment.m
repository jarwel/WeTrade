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

- (NSString *)timeElapsedText {
    int time = [[NSDate date] timeIntervalSinceDate:self.createdAt];
    if (time > 60) {
        time = time / 60;
        if (time > 60) {
            time = time / 60;
            if (time > 24) {
                time = time / 24;
                return [NSString stringWithFormat:@"%d day%@ ago", time, time == 1 ? @"" : @"s" ];
            }
            return [NSString stringWithFormat:@"%d hour%@ ago", time, time == 1 ? @"" : @"s"];
        }
        return [NSString stringWithFormat:@"%d minute%@ ago", time, time == 1 ? @"" : @"s"];
    }
    return [NSString stringWithFormat:@"%d second%@ ago", time, time == 1 ? @"" : @"s"];
}

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [comments addObject:[[Comment alloc] initWithData:object]];
    }
    return comments;
}

@end
