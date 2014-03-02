//
//  FinanceClient.m
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FinanceClient.h"
#import "Constants.h"

@implementation FinanceClient

+ (FinanceClient *)instance {
    static FinanceClient *instance;
    if (! instance) {
        instance = [[FinanceClient alloc] init];
    }
    return instance;
}

- (void)fetchQuotesForPositions:(NSArray *)positions callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSLog(@"fetchQuotesForPositions: %ld", positions.count);
    
    NSMutableString *symbols = [[NSMutableString alloc] initWithString:@""];
    for (Position *position in positions) {
        if (![CashSymbol isEqualToString:position.symbol]) {
            [symbols appendFormat:@"'%@',", position.symbol];
        }
    }
    
    if (symbols.length > 0) {
        NSLog(@"fetchQuotesForSymbols: %@", symbols);
        
        NSString *query = [NSString stringWithFormat:@"select symbol, Name, LastTradePriceOnly, Change, ChangeinPercent, PreviousClose from yahoo.finance.quotes where symbol in (%@)", [symbols substringToIndex:symbols.length - 1]];
        NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];

        [self staleWhileRevalidate:url callback:callback];
    }
}

- (void)fetchFullQuoteForSymbol:(NSString *)symbol callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSLog(@"fetchFullQuoteForSymbol: %@", symbol);
    
    NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.quotes where symbol = '%@'", symbol];
    NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
    
    [self staleWhileRevalidate:url callback:callback];
}

- (void)fetchHistoryForSymbol:(NSString *)symbol startDate:(NSDate *)startDate endDate:(NSDate *)endDate callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *start = [dateFormatter stringFromDate:startDate];
    NSString *end = [dateFormatter stringFromDate:endDate];
    NSLog(@"fetchHistoryForSymbol: %@ start: %@ end: %@", symbol, start, end);
    
    NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.historicaldata where symbol = '%@' and startDate = '%@' and endDate = '%@'", symbol, start, end];
    NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
}

- (void)staleWhileRevalidate:(NSString *)url callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *cached = [defaults objectForKey:url];
    if (cached) {
        callback(nil, cached, nil);
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [defaults setObject:data forKey:url];
        [defaults synchronize];
        callback(response, data, connectionError);
    }];
}


@end
