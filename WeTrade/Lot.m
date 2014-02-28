//[
//  Lot.m
//  WeTrade
//
//  Created by Jason Wells on 1/23/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Lot.h"

@implementation Lot

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

+ (NSMutableArray *)fromObjects:(NSArray *)objects {
    NSMutableArray *lots = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject *object in objects) {
        [lots addObject:[[Lot alloc] initWithData:object]];
    }
    return lots;
}

@end
