//
//  ParseObject.m
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "ParseObject.h"

@implementation ParseObject

- (id)initWithObject:(PFObject *)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

@end
