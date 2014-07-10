//
//  Quotes.m
//  WeTrade
//
//  Created by Jason Wells on 1/27/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Quote.h"

@implementation Quote

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _symbol = [dictionary objectForKey:@"symbol"];
        _name = [dictionary objectForKey:@"Name"];
        _price = [[dictionary objectForKey:@"LastTradePriceOnly"] floatValue];
        _priceChange = [[dictionary objectForKey:@"Change"] floatValue];
        _percentChange =[[dictionary objectForKey:@"ChangeinPercent"] floatValue];
        _previousClose = [[dictionary objectForKey:@"PreviousClose"] floatValue];
        
    }
    return self;
}

+ (Quote *)fromDictionary:(NSDictionary *)dictionary {
    if ([dictionary objectForKey:@"ErrorIndicationreturnedforsymbolchangedinvalid"] == [NSNull null]) {
        return [[Quote alloc] initWithDictionary:dictionary];
    }
    return nil;
}

+ (NSArray *)fromData:(NSData *)data {
    NSMutableArray *quotes = [[NSMutableArray alloc] init];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *query = [dictionary objectForKey:@"query"];
    int count = [[query objectForKey:@"count"] intValue];
    if (count == 1) {
        NSDictionary *results = [query objectForKey:@"results"];
        NSDictionary *dictionary = [results objectForKey:@"quote"];
        Quote* quote = [Quote fromDictionary:dictionary];
        if (quote) {
            [quotes addObject:quote];
        }
    }
    if (count > 1) {
        NSDictionary *results = [query objectForKey:@"results"];
        for (NSDictionary *dictionary in [results objectForKey:@"quote"]) {
            Quote* quote = [Quote fromDictionary:dictionary];
            if (quote) {
                [quotes addObject:quote];
            }
        }
    }
    return quotes;
}

@end
