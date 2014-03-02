//
//  FullQuote.m
//  WeTrade
//
//  Created by Jason Wells on 3/2/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FullQuote.h"

@implementation FullQuote

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

- (float)open {
    NSString *open = [self objectForKey:@"Open"];
    if (open) {
        return [open floatValue];
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

- (float)high {
    NSString *high = [self objectForKey:@"DaysHigh"];
    if (high) {
        return [high floatValue];
    }
    return 0;
}

- (float)low {
    NSString *low = [self objectForKey:@"DaysLow"];
    if (low) {
        return [low floatValue];
    }
    return 0;
}

- (float)oneYearTarget {
    NSString *oneYearTarget = [self objectForKey:@"OneyrTargetPrice"];
    if (oneYearTarget) {
        return [oneYearTarget floatValue];
    }
    return 0;
}

- (float)volume {
    NSString *volume = [self objectForKey:@"Volume"];
    if (volume) {
        return [volume floatValue];
    }
    return 0;
}

- (NSString *)marketCapitalization {
    return [self objectForKey:@"MarketCapitalization"];
}

- (NSString *)ebitda {
    return [self objectForKey:@"EBITDA"];
}

- (float)pricePerEarnings {
    NSString *pricePerEarnings = [self objectForKey:@"PERatio"];
    if (pricePerEarnings) {
        return [pricePerEarnings floatValue];
    }
    return 0;
}

- (float)earningsPerShare {
    NSString *earningPerShare = [self objectForKey:@"PriceEPSEstimateCurrentYear"];
    if (earningPerShare) {
        return [earningPerShare floatValue];
    }
    return 0;
}

- (float)dividend {
    NSString *dividend = [self objectForKey:@"DividendShare"];
    if (dividend) {
        return [dividend floatValue];
    }
    return 0;
}

- (float)yield {
    NSString *yield = [self objectForKey:@"DividendYield"];
    if (yield) {
        return [yield floatValue];
    }
    return 0;
}

- (NSString *)exDividendDate {
    return [self objectForKey:@"ExDividendDate"];
}

- (NSString *)dividendDate {
    return [self objectForKey:@"DividendPayDate"];
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

+ (FullQuote *)fromData:(NSData *)data {
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *query = [dictionary objectForKey:@"query"];
    
    int count = [[query objectForKey:@"count"] intValue];
    if (count == 1) {
        NSDictionary *results = [query objectForKey:@"results"];
        NSDictionary *dictionary = [results objectForKey:@"quote"];
        FullQuote *fullQuote = [[FullQuote alloc] initWithDictionary:dictionary];
        return fullQuote;
    }
    return nil;
}

@end
