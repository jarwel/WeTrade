//
//  QuoteService.m
//  WeTrade
//
//  Created by Jason Wells on 3/6/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "QuoteService.h"
#import "Constants.h"
#import "FinanceClient.h"

@interface QuoteService ()

@property (strong, nonatomic) NSMutableDictionary *quotes;

- (void)reloadQuotes;
- (void)clearQuotes;

@end

@implementation QuoteService

+ (QuoteService *)instance {
    static QuoteService *instance;
    if (!instance) {
        instance = [[QuoteService alloc] init];
    }
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _quotes = [[NSMutableDictionary alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reloadQuotes) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearQuotes) name:LogoutNotification object:nil];
    }
    return self;
}

- (Quote *)quoteForSymbol:(NSString *)symbol {
    Quote *quote = [self.quotes objectForKey:symbol];
    
    if (!quote && ![symbol isEqualToString:CashSymbol]) {
        NSMutableSet *symbols = [[NSMutableSet alloc] init];
        [symbols addObject:symbol];
        
        [self.quotes setObject:[[Quote alloc] init] forKey:symbol];
        [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSArray *quotes) {
            if (quotes.count > 0) {
                for (Quote *quote in quotes) {
                    [self.quotes setObject:quote forKey:quote.symbol];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:QuotesUpdatedNotification object:nil];
            }
        }];
    }

    return quote;
}

- (NSDictionary *)quotesForSymbols:(NSSet *)symbols {
    NSMutableDictionary *quotes = [[NSMutableDictionary alloc] init];
    NSMutableSet *missingSymbols = [[NSMutableSet alloc] init];
    
    for (NSString *symbol in symbols) {
        Quote *quote = [self.quotes objectForKey:symbol];
        
        if (!quote && ![symbol isEqualToString:CashSymbol]) {
            [self.quotes setObject:[[Quote alloc] init] forKey:symbol];
            [missingSymbols addObject:symbol];
        }
        else {
            [quotes setObject:quote forKey:symbol];
        }
    }
    
    if (missingSymbols.count > 0) {
        [[FinanceClient instance] fetchQuotesForSymbols:missingSymbols callback:^(NSArray *quotes) {
            if (quotes.count > 0) {
                for (Quote *quote in quotes) {
                    [self.quotes setObject:quote forKey:quote.symbol];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:QuotesUpdatedNotification object:nil];
            }
        }];
    }
    
    return quotes;
}

- (void)reloadQuotes {
    if (self.quotes.count > 0) {
        NSSet *symbols = [NSSet setWithArray:self.quotes.allKeys];
        [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSArray *quotes) {
            if (quotes.count > 0) {
                for (Quote *quote in quotes) {
                    [self.quotes setObject:quote forKey:quote.symbol];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:QuotesUpdatedNotification object:nil];
            }
        }];
    }
}

- (void)clearQuotes {
    [self.quotes removeAllObjects];
}

@end
