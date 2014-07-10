//
//  Metrics.m
//  WeTrade
//
//  Created by Jason Wells on 3/2/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "Metrics.h"

@implementation Metrics


- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _symbol = [dictionary objectForKey:@"symbol"];
        _name = [dictionary objectForKey:@"Name"];
        _price = [[dictionary objectForKey:@"LastTradePriceOnly"] floatValue];
        _priceChange = [[dictionary objectForKey:@"Change"] floatValue];
        _percentChange =[[dictionary objectForKey:@"ChangeinPercent"] floatValue];
        _open = [[dictionary objectForKey:@"LastTradePriceOnly"] floatValue];
        _previousClose = [[dictionary objectForKey:@"PreviousClose"] floatValue];
        _high = [[dictionary objectForKey:@"DaysHigh"] floatValue];
        _low = [[dictionary objectForKey:@"DaysLow"] floatValue];
        _oneYearTarget = [[dictionary objectForKey:@"OneyrTargetPrice"] floatValue];
        _volume = [[dictionary objectForKey:@"Volume"] floatValue];
        _marketCapitalization = [dictionary objectForKey:@"MarketCapitalization"];
        _ebitda = [dictionary objectForKey:@"EBITDA"];
        _pricePerEarnings = [[dictionary objectForKey:@"PERatio"] floatValue];
        _earningsPerShare = [[dictionary objectForKey:@"PriceEPSEstimateCurrentYear"] floatValue];
        _dividend = [[dictionary objectForKey:@"DividendShare"] floatValue];
        if ([dictionary objectForKey:@"DividendYield"] != [NSNull null]) {
            _yield = [[dictionary objectForKey:@"DividendYield"] floatValue];
        }
        _exDividendDate = [dictionary objectForKey:@"ExDividendDate"];
        _dividendDate = [dictionary objectForKey:@"DividendPayDate"];
    }
    return self;
}

- (NSString *)volumeText {
    float volume = self.volume / 1000;
    if (volume > 1000) {
        volume = volume / 1000;
        if (volume > 1000) {
            volume = volume / 1000;
            return [NSString stringWithFormat:@"%0.2fB", volume];
        }
        return [NSString stringWithFormat:@"%0.2fM", volume];
    }
    return [NSString stringWithFormat:@"%0.2fK", volume];
}

+ (Metrics*)fromData:(NSData *)data {
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *query = [dictionary objectForKey:@"query"];
    
    int count = [[query objectForKey:@"count"] intValue];
    if (count == 1) {
        NSDictionary *results = [query objectForKey:@"results"];
        NSDictionary *dictionary = [results objectForKey:@"quote"];
        Metrics *metrics = [[Metrics alloc] initWithDictionary:dictionary];
        return metrics;
    }
    return nil;
}

@end
