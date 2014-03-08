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

- (void)fetchQuotesForSymbols:(NSSet *)symbols callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    if (symbols.count > 0) {
        NSString *symbolString = [NSString stringWithFormat:@"'%@'", [[symbols allObjects] componentsJoinedByString:@"','"]];
        NSLog(@"fetchQuotesForSymbols: %@", symbolString);

        NSString *query = [NSString stringWithFormat:@"select symbol, Name, LastTradePriceOnly, Change, ChangeinPercent, PreviousClose, ErrorIndicationreturnedforsymbolchangedinvalid from yahoo.finance.quotes where symbol in (%@)", symbolString];
        NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
    }
}

- (void)fetchSectorsForSymbols:(NSSet *)symbols callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    if (symbols.count > 0) {
        NSString *symbolString = [NSString stringWithFormat:@"'%@'", [[symbols allObjects] componentsJoinedByString:@"','"]];
        NSLog(@"fetchSectorsForSymbols: %@", symbolString);
        
        NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.stocks where symbol in (%@)", symbolString];
        NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
    }
}

- (void)fetchMetricsForSymbol:(NSString *)symbol callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    if (symbol) {
        NSLog(@"fetchFullQuoteForSymbol: %@", symbol);
    
        NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.quotes where symbol = '%@'", symbol];
        NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
    
        [self staleWhileRevalidate:url callback:callback];
    }
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *cached = [defaults objectForKey:url];
    if (cached) {
        callback(nil, cached, nil);
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [defaults setObject:data forKey:url];
        callback(response, data, connectionError);
    }];
}


@end
