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
    return [self.data objectForKey:@"symbol"];
}

- (float)price {
    return [[self.data objectForKey:@"LastTradePriceOnly"] floatValue];
}

- (float)percentChange {
    return [[self.data objectForKey:@"PercentChange"] floatValue];
}

@end
