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
#import "FinanceClient.h"
#import "Position.h"
#import "Quote.h"

@interface PortfolioService ()

@property (strong, nonatomic) NSMutableArray *lots;
@property (strong, nonatomic) NSDictionary *sectors;

- (void)reload;
- (void)clear;

@end

@implementation PortfolioService

+ (PortfolioService *)instance {
    static PortfolioService *instance;
    if (!instance) {
        instance = [[PortfolioService alloc] init];
        [instance reload];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:LoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:LogoutNotification object:nil];
    }
    return self;
}

- (NSArray *)positions {
    NSMutableDictionary *positions = [[NSMutableDictionary alloc] init];
    for (Lot *lot in self.lots) {
        NSString *symbol = lot.symbol;
        
        if ([lot.cash boolValue]) {
            symbol = CashSymbol;
        }
        
        if (![positions objectForKey:symbol]) {
            Position *position = [[Position alloc] init];
            position.symbol = symbol;
            position.sector = [self.sectors objectForKey:symbol];
            [positions setObject:position forKey:symbol];
        }
        Position *position = [positions objectForKey:symbol];
        [position addLot:lot];
    }
    return [positions allValues];
}

- (void)markCashSymbol:(NSString *)symbol {
    for (Lot *lot in self.lots) {
        if ([lot.symbol isEqualToString:symbol]) {
            lot.cash = @"YES";
            [[ParseClient instance] updateLot:lot withCash:@"Yes"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PortfolioChangedNotification object:nil];
}

- (void)unmarkCashSymbol:(NSString *)symbol {
    for (Lot *lot in self.lots) {
        if ([lot.symbol isEqualToString:symbol]) {
            lot.cash = @"NO";
            [[ParseClient instance] updateLot:lot withCash:@"NO"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PortfolioChangedNotification object:nil];
}

- (void)addLots:(NSArray *)lots fromSource:(NSString *)source; {
    NSMutableArray *removes = [[NSMutableArray alloc] init];
    for (Lot *lot in self.lots) {
        if ([lot.source isEqualToString:source]) {
            [removes addObject:lot];
        }
    }
    [[ParseClient instance] removeLots:removes callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[ParseClient instance] createLots:lots withSource:source callback:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self reload];
                }
            }];
        }
    }];
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

+ (NSSet *)sectorsForPositions:(NSArray *)positions {
    NSMutableSet *sectors = [[NSMutableSet alloc] init];
    for (Position *position in positions) {
        if (position.sector) {
            [sectors addObject:position.sector];
        }
    }    return sectors;
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

+ (void)positionsForUserId:(NSString *)userId callback:(void (^)(NSArray *positions))callback {
    [[ParseClient instance] fetchLotsForUserId:userId callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *positions = [Position fromObjects:objects];
            NSSet *symbols = [self symbolsForPositions:positions];
            [[FinanceClient instance] fetchSectorsForSymbols:symbols callback:^(NSDictionary *sectors) {
                for (Position *position in positions) {
                    NSString *sector = [sectors objectForKey:position.symbol];
                    position.sector = sector;
                }
                callback(positions);
            }];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)reload {
    [[ParseClient instance] fetchLots:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *lots = [Lot fromParseObjects:objects];
            NSMutableSet *symbols = [[NSMutableSet alloc] init];
            for (Lot *lot in lots) {
                [symbols addObject:lot.symbol];
            }
            [[FinanceClient instance] fetchSectorsForSymbols:symbols callback:^(NSDictionary *sectors) {
                _sectors = sectors;
                _lots = lots;
                [[NSNotificationCenter defaultCenter] postNotificationName:PortfolioChangedNotification object:nil];
            }];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)clear {
    [self.lots removeAllObjects];
}

@end
