//
//  Comment.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Comment.h"

@implementation Comment

- (NSString *)symbol {
    return [self.data objectForKey:@"symbol"];
}

- (NSString *)text {
    return [self.data objectForKey:@"text"];
}

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [comments addObject:[[Comment alloc] initWithData:object]];
    }
    return comments;
}

@end
