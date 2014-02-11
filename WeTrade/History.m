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

+ (History *)fromJSONDictionary:(NSDictionary *)dictionary {
    History *history = [[History alloc] init];
    
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    float low = FLT_MAX;
    float high = FLT_MIN;
        
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
    history.priceLow = low;
    history.priceHigh = high;
    return history;
}

@end
