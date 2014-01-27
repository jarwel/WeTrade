//
//  Position.m
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Position.h"
#import "Lot.h"

@implementation Position

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableDictionary *positions = [NSMutableDictionary dictionary];
    for (PFObject *object in objects) {
        NSString *symbol = [object objectForKey:@"symbol"];
        if([positions valueForKey:symbol] == nil) {
            [positions setObject:[[Position alloc] init] forKey:symbol];
        }
        Position *position = [positions objectForKey:symbol];
        [position.lots addObject:[[Lot alloc] initWithObject:object]];
    }
    return [[NSMutableArray alloc] initWithArray:[positions allValues]];
}

- (id)init {
    if (self = [super init]) {
        _lots = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)symbol {
    Lot *lot = [_lots firstObject];
    return lot.symbol;
}

@end
