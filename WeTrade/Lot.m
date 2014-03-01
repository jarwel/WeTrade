//[
//  Lot.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Lot.h"

@implementation Lot

- (id)initWithSymbol:(NSString *)symbol shares:(float)shares costBasis:(float)costBasis {
    if (self = [super init]) {
        _symbol = symbol;
        _shares = shares;
        _costBasis = costBasis;
    }
    return self;
}

- (NSString *)symbol {
    if (!_symbol) {
        _symbol = [self.data objectForKey:@"symbol"];
    }
    return _symbol;
}

- (float)shares {
    if (!_shares) {
        _shares = [[self.data objectForKey:@"shares"] floatValue];
    }
    return _shares;
}

- (float)costBasis {
    if (!_costBasis) {
        _costBasis = [[self.data objectForKey:@"costBasis"] floatValue];
    }
    return _costBasis;
}

- (NSString *)cash {
    if (!_cash) {
        _cash = [self.data objectForKey:@"cash"];
    }
    return _cash;
}

- (BOOL)mightBeCash {
    if ([self.cash boolValue] || self.costBasis == 0) {
        return YES;
    }
    return NO;
}

+ (NSMutableArray *)fromObjects:(NSArray *)objects {
    NSMutableArray *lots = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [lots addObject:[[Lot alloc] initWithData:object]];
    }
    return lots;
}

@end
