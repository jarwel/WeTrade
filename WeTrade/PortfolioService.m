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

@property (strong, nonatomic) NSArray *portfolio;

- (void)clear;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:LogoutNotification object:nil];
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

+ (void)fetchPositionsForUserId:(NSString *)userId callback:(void (^)(NSArray *positions))callback {
    [[ParseClient instance] fetchLotsForUserId:userId callback:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSArray *positions = [Position fromObjects:objects];
            NSSet *symbols = [self symbolsForPositions:positions];
            [[FinanceClient instance] fetchSectorsForSymbols:symbols callback:^(NSURLResponse *response, NSData *data, NSError *error) {
                NSMutableDictionary *sectors = [[NSMutableDictionary alloc] init];
                if (!error) {
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSDictionary *query = [dictionary objectForKey:@"query"];
                    int count = [[query objectForKey:@"count"] intValue];
                    if (count > 0) {
                       NSDictionary *results = [query objectForKey:@"results"];
                        if (count == 1) {
                            NSDictionary *stock = [results objectForKey:@"stock"];
                            NSString *symbol = [stock objectForKey:@"symbol"];
                            NSString *sector = [stock objectForKey:@"Sector"];
                            if (sector) {
                                [sectors setObject:sector forKey:symbol];
                            }
                        }
                        else {
                            for (NSDictionary *stock in [results objectForKey:@"stock"]) {
                                NSString *symbol = [stock objectForKey:@"symbol"];
                                NSString *sector = [stock objectForKey:@"Sector"];
                                if (sector) {
                                    [sectors setObject:sector forKey:symbol];
                                }
                            }
                        }
                    }
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                
                for (Position *position in positions) {
                    NSString *sector = [sectors objectForKey:position.symbol];
                    position.sector = sector;
                }
                callback(positions);
            }];

        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)update {
    PFUser *currentUser = [PFUser currentUser];
    [PortfolioService fetchPositionsForUserId:currentUser.objectId callback:^(NSArray *positions) {
        _portfolio = positions;
        [[NSNotificationCenter defaultCenter] postNotificationName:PortfolioChangedNotification object:nil];
    }];
}

- (void)clear {
    _portfolio = [[NSArray alloc] init];
}

@end
