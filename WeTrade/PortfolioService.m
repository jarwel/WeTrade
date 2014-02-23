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

+ (NSNumber *)getChangeForPositions:(NSArray *)positions quotes:(NSDictionary *)quotes {
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
