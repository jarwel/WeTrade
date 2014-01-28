//
//  Position.m
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Position.h"
#import "Lot.h"

@interface Position ()

@property (nonatomic, strong) NSMutableArray *lots;

@end

@implementation Position

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableDictionary *positions = [NSMutableDictionary dictionary];
    for (PFObject *object in objects) {
        NSString *symbol = [object objectForKey:@"symbol"];
        if ([positions valueForKey:symbol] == nil) {
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

- (int)shares {
    int shares = 0;
    for (Lot *lot in _lots) {
        shares += lot.shares;
    }
    return shares;
}

- (float)costBasis {
    float costBasis = 0;
    for (Lot *lot in _lots) {
        costBasis += lot.costBasis;
    }
    return costBasis;
}

- (float)valueForQuote:(Quote *)quote {
    if (quote) {
        return self.shares * quote.price;
    }
    return 0;
}

@end
