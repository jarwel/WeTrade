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

+ (NSMutableDictionary *)fromJSONDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *quotes = [[NSMutableDictionary alloc] init];
    NSDictionary *query = [dictionary objectForKey:@"query"];
    
    int count = [[query objectForKey:@"count"] intValue];
    if (count == 0) {
        return quotes;
    }
    if (count == 1) {
        NSDictionary *results = [query objectForKey:@"results"];
        NSDictionary *data = [results objectForKey:@"quote"];
        Quote *quote = [[Quote alloc] initWithData:data];
        [quotes setObject:quote forKey:quote.symbol];
    }
    else {
        NSDictionary *results = [query objectForKey:@"results"];
        for (NSDictionary *data in [results objectForKey:@"quote"]) {
            Quote *quote = [[Quote alloc] initWithData:data];
            [quotes setObject:quote forKey:quote.symbol];
        }
    }
    return quotes;
}

@end
