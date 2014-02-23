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

- (NSString *)name {
    return [self.data objectForKey:@"Name"];
}

- (float)price {
    return [[self.data objectForKey:@"LastTradePriceOnly"] floatValue];
}

- (float)percentChange {
    return [[self.data objectForKey:@"ChangeinPercent"] floatValue];
}

+ (NSMutableDictionary *)fromData:(NSData *)data {
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
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
