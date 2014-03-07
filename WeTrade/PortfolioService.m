//
//  PortfolioService.m
//  WeTrade
//
//  Created by Jason Wells on 2/22/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "PortfolioService.h"
#import "Constants.h"
#import "ParseClient.h"
#import "Position.h"
#import "Quote.h"

@interface PortfolioService ()

@property (strong, nonatomic) NSArray *portfolio;

@end

@implementation PortfolioService

+ (PortfolioService *)instance {
    static PortfolioService *instance;
    if (!instance) {
        instance = [[PortfolioService alloc] init];
        [instance update];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:LoginNotification object:nil];
    }
    return self;
}

- (NSArray *)positions {
    return self.portfolio;
}

+ (NSSet *)symbolsForPositions:(NSArray *)positions {
    NSMutableSet *symbols = [[NSMutableSet alloc] init];
    for (Position *position in positions) {
        if (![position.symbol isEqualToString:CashSymbol]) {
            [symbols addObject:position.symbol];
        }
    }
    return symbols;
}

+ (NSNumber *)totalValueForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions {
    float total = 0;
    for (Position *position in positions ) {
        total += [position valueForQuote:[quotes objectForKey:position.symbol]];
    }
    return [NSNumber numberWithFloat:total];
}

+ (NSNumber *)totalChangeForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions {
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

+ (NSNumber *)dayChangeForQuotes:(NSDictionary *)quotes positions:(NSArray *)positions {
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

+ (UIColor *)colorForChange:(float)change {
    if (change > 0) {
        return [UIColor greenColor];
    }
    if (change < 0) {
        return [UIColor redColor];
    }
    return [UIColor blueColor];
}

- (void)update {
    [[ParseClient instance] fetchLots:^(NSArray *objects, NSError *error) {
        if (!error) {
            _portfolio = [Position fromObjects:objects];
            [[NSNotificationCenter defaultCenter] postNotificationName:PortfolioChangedNotification object:nil];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

@end
