//
//  Security.m
//  WeTrade
//
//  Created by Jason Wells on 3/4/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Security.h"

@implementation Security

- (id)initWithSymbol:(NSString *)symbol {
    if (self = [super init]) {
        _symbol = symbol;
    }
    return self;
}

- (NSString *)objectId {
    return self.data.objectId;
}

- (NSString *)symbol {
    if (!_symbol) {
        _symbol = [self.data objectForKey:@"symbol"];
    }
    return _symbol;
}

+ (NSMutableArray *)fromParseObjects:(NSArray *)parseObjects {
    NSMutableArray *securities = [[NSMutableArray alloc] initWithCapacity:parseObjects.count];
    for (PFObject *parseObject in parseObjects) {
        [securities addObject:[[Security alloc] initWithData:parseObject]];
    }
    return securities;
}

@end
