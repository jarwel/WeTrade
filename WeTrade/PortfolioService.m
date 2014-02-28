//
//  PortfolioService.m
//  WeTrade
//
//  Created by Jason Wells on 2/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "PortfolioService.h"
#import "Position.h"
#import "Quote.h"

@implementation PortfolioService

+ (NSNumber *)getDayChangeForPositions:(NSArray *)positions quotes:(NSDictionary *)quotes {
    float priceChange = 0;
    float previousClose = 0;
    
    for (Position *position in positions) {
        Quote *quote = [quotes objectForKey:position.symbol];
        priceChange += position.shares * quote.priceChange;
        previousClose += position.shares * quote.previousClose;
    }
    
    if (previousClose > 0) {
        return [[NSNumber alloc] initWithFloat:(float)priceChange / previousClose * 100];
    }
    return nil;
}

+ (NSNumber *)getTotalChangeForPositions:(NSArray *)positions quotes:(NSDictionary *)quotes {
    float currentValue = 0;
    float costBasis = 0;
    
    for (Position *position in positions) {
        Quote *quote = [quotes objectForKey:position.symbol];
        currentValue += [position valueForQuote:quote];
        costBasis += position.costBasis;
    }
    
    if (costBasis > 0 && currentValue > 0) {
        return [[NSNumber alloc] initWithFloat:(currentValue - costBasis) / costBasis * 100];
    }
    return nil;
}

+ (UIColor *)getColorForChange:(float)change {
    if (change > 0) {
        return [UIColor greenColor];
    }
    if (change < 0) {
        return [UIColor redColor];
    }
    return [UIColor blueColor];
}

@end
