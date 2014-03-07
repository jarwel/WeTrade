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

- (void)update;
- (void)clear;

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
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:LogoutNotification object:nil];
    }
    return self;
}

- (Quote *)quoteForSymbol:(NSString *)symbol {
    Quote *quote = [self.quotes objectForKey:symbol];
    
    if (!quote && ![symbol isEqualToString:CashSymbol]) {
        NSMutableSet *symbols = [[NSMutableSet alloc] init];
        [symbols addObject:symbol];
        
        [self.quotes setObject:[[Quote alloc] init] forKey:symbol];
        [self fetchQuotesForSymbols:symbols];
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
        [self fetchQuotesForSymbols:missingSymbols];
    }
    
    return quotes;
}


- (void)fetchQuotesForSymbols:(NSSet *)symbols {
    [[FinanceClient instance] fetchQuotesForSymbols:symbols callback:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSArray *quotes = [Quote fromData:data];
            for (Quote *quote in quotes) {
                [self.quotes setObject:quote forKey:quote.symbol];
            }
            if (quotes.count > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:QuotesUpdatedNotification object:nil];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)update {
    if (self.quotes.count > 0) {
        [[FinanceClient instance] fetchQuotesForSymbols:[NSSet setWithArray:self.quotes.allKeys] callback:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (!error) {
                NSArray *quotes = [Quote fromData:data];
                if (quotes.count > 0) {
                    [self.quotes setObject:quotes.firstObject forKey:((Quote *)quotes.firstObject).symbol];
                    [[NSNotificationCenter defaultCenter] postNotificationName:QuotesUpdatedNotification object:nil];
                }
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

- (void)clear {
    [self.quotes removeAllObjects];
}

@end