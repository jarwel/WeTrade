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
@property (strong, nonatomic) NSTimer *reloadTimer;

- (void)updateTimer;
- (void)reload;
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
        [self updateTimer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:LogoutNotification object:nil];
    }
    return self;
}

- (void)updateTimer {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    NSInteger hour = [[calendar components:NSHourCalendarUnit fromDate:now] hour];
    
    int seconds;
    if (hour > 8 && hour < 17) {
        _reloadTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reload) userInfo:nil repeats:YES];
        seconds = [[self marketCloseFromDate:now] timeIntervalSinceDate:now];
        NSLog(@"Seconds until close: %d", seconds);
        
    }
    else {
        [self.reloadTimer invalidate];
        _reloadTimer = nil;
        seconds = [[self marketOpenFromDate:now] timeIntervalSinceDate:now];
        NSLog(@"Seconds until open: %d", seconds);
    }
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(updateTimer) userInfo:nil repeats:NO];
}

- (NSDate *)marketOpenFromDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:date];
    [dateComponents setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    if ([dateComponents hour] > 8) {
        [dateComponents setDay:[dateComponents day] + 1];
    }
    [dateComponents setHour:8];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    return [calendar dateFromComponents:dateComponents];
}

- (NSDate *)marketCloseFromDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate:date];
    [dateComponents setTimeZone:[NSTimeZone timeZoneWithName:@"US/Eastern"]];
    if ([dateComponents hour] > 17) {
        [dateComponents setDay:[dateComponents day] + 1];
    }
    [dateComponents setHour:17];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    return [calendar dateFromComponents:dateComponents];
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

- (void)reload {
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

- (void)clear {
    [self.quotes removeAllObjects];
}

@end
