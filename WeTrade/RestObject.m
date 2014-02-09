//
//  RestObject.m
//  WeTrade
//
//  Created by Jason Wells on 2/8/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "RestObject.h"

@implementation RestObject

- (id)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

@end
