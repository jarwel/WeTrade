//
//  Position.m
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Position.h"
#import "Lot.h"
#import "Constants.h"

@interface Position ()

@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, assign) int shares;
@property (nonatomic, assign) float costBasis;
@property (nonatomic, assign) BOOL isCash;
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
    if (!_symbol && self.lots.count > 0) {
        Lot *lot = [self.lots firstObject];
        _symbol = [lot.cash boolValue] ? CashSymbol :lot.symbol;
    }
    return _symbol;
}

- (int)shares {
    if (_shares == 0) {
        for (Lot *lot in self.lots) {
            _shares += lot.shares;
        }
    }
    return _shares;
}

- (float)costBasis {
    if (_costBasis == 0) {
        for (Lot *lot in self.lots) {
            _costBasis += lot.costBasis;
        }
    }
    return _costBasis;
}

- (float)valueForQuote:(Quote *)quote {
    if ([CashSymbol isEqualToString:self.symbol]) {
        return self.shares;
    }
    return self.shares * quote.price;
}

+ (NSArray *)fromObjects:(NSArray *)objects {
    NSMutableDictionary *positions = [NSMutableDictionary dictionary];
    for (PFObject *object in objects) {
        NSString *symbol = [object objectForKey:@"symbol"];
        
        if ([[object objectForKey:@"cash"] boolValue] ) {
            symbol = CashSymbol;
        }
        
        if ([positions valueForKey:symbol] == nil) {
            [positions setObject:[[Position alloc] init] forKey:symbol];
        }
        Position *position = [positions objectForKey:symbol];
        [position.lots addObject:[[Lot alloc] initWithData:object]];
    }
    return [[NSArray alloc] initWithArray:[positions allValues]];
}

@end
