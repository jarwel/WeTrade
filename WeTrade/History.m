//
//  History.m
//  WeTrade
//
//  Created by Jason Wells on 2/11/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "History.h"
#import "HistoricalQuote.h"

@implementation History

- (NSDate *)startDate {
    HistoricalQuote *quote = [self.quotes objectAtIndex:0];
    return quote.date;
}

- (NSDate *)endDate {
    HistoricalQuote *quote = [self.quotes lastObject];
    return quote.date;
}

- (float)startPrice {
    if (self.quotes.count > 0) {
        HistoricalQuote *quote = [self.quotes objectAtIndex:0];
        return quote.close;
    }
    return 0;
}

- (float)endPrice {
    if (self.quotes.count > 0) {
        HistoricalQuote *quote = [self.quotes lastObject];
        return quote.close;
    }
    return 0;
}

+ (History *)fromData:(NSData *)data {
    History *history = [[History alloc] init];
    
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    float low = FLT_MAX;
    float high = FLT_MIN;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *query = [dictionary objectForKey:@"query"];
    int count = [[query objectForKey:@"count"] intValue];
    if (count != 0) {
        NSDictionary *results = [query objectForKey:@"results"];
        NSArray *array = [results objectForKey:@"quote"];
        for (NSDictionary *data in array) {
            HistoricalQuote *historicalQuote = [[HistoricalQuote alloc] initWithData:data];
            if(historicalQuote.close < low) {
                low = historicalQuote.close;
            }
            if(historicalQuote.close > high) {
                high = historicalQuote.close;
            }
            [quotes addObject:historicalQuote];
        }
    }
    history.quotes = [[quotes reverseObjectEnumerator] allObjects];
    history.lowPrice = low;
    history.highPrice = high;
    return history;
}

@end
