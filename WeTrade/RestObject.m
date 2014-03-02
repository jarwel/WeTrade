//
//  RestObject.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "RestObject.h"

@implementation RestObject

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _dictionary = dictionary;
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    if ([self.dictionary objectForKey:key] == [NSNull null]) {
        return nil;
    }
    return [self.dictionary objectForKey:key];
}

@end
