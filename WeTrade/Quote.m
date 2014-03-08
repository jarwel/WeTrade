//
//  Quotes.m
//  WeTrade
//
//  Created by Jason Wells on 1/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Quote.h"

@implementation Quote

- (NSString *)symbol {
    return [self objectForKey:@"symbol"];
}

- (NSString *)name {
    return [self objectForKey:@"Name"];
}

- (float)price {
    NSString *price = [self objectForKey:@"LastTradePriceOnly"];
    if (price) {
        return [price floatValue];
    }
    return 0;
}

- (float)priceChange {
    NSString *priceChange = [self objectForKey:@"Change"];
    if (priceChange) {
        return [priceChange floatValue];
    }
    return 0;
}

- (float)percentChange {
    NSString *percentChange = [self objectForKey:@"ChangeinPercent"];
    if (percentChange) {
        return [percentChange floatValue];
    }
    return 0;
}

- (float)previousClose {
    NSString *previousClose = [self objectForKey:@"PreviousClose"];
    if (previousClose) {
        return [previousClose floatValue];
    }
    return 0;
}

- (BOOL)isValid {
    if ([self objectForKey:@"ErrorIndicationreturnedforsymbolchangedinvalid"]) {
        return NO;
    }
    return YES;
}

@end
