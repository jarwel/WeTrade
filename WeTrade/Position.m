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

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, assign) int shares;
@property (nonatomic, assign) float costBasis;
@property (nonatomic, strong) NSMutableArray *lots;

@end

@implementation Position

- (id)init {
    if (self = [super init]) {
        _lots = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)symbol {
    if (! _symbol) {
        Lot *lot = [_lots firstObject];
        _symbol = lot.symbol;
    }
    return _symbol;
}

- (int)shares {
    if (_shares == 0) {
        for (Lot *lot in _lots) {
            _shares += lot.shares;
        }
    }
    return _shares;
}

- (float)costBasis {
    if (_costBasis == 0) {
        for (Lot *lot in _lots) {
            _costBasis += lot.costBasis;
        }
    }
    return _costBasis;
}

- (float)valueForQuote:(Quote *)quote {
    if (quote) {
        return self.shares * quote.price;
    }
    return 0;
}

+ (NSMutableArray *)fromPFObjectArray:(NSArray *)objects {
    NSMutableDictionary *positions = [NSMutableDictionary dictionary];
    for (PFObject *object in objects) {
        NSString *symbol = [object objectForKey:@"symbol"];
        if ([positions valueForKey:symbol] == nil) {
            [positions setObject:[[Position alloc] init] forKey:symbol];
        }
        Position *position = [positions objectForKey:symbol];
        [position.lots addObject:[[Lot alloc] initWithData:object]];
    }
    return [[NSMutableArray alloc] initWithArray:[positions allValues]];
}

@end
