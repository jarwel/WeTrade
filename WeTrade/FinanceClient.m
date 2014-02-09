//
//  FinanceClient.m
//  WeTrade
//
//  Created by Jason Wells on 1/26/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "FinanceClient.h"

@implementation FinanceClient

+ (FinanceClient *)instance {
    static FinanceClient *instance;
    
    if (! instance) {
        instance = [[FinanceClient alloc] init];
    }
    return instance;
}

- (void)fetchQuotesForSymbols:(NSArray *)array callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSString *symbols = [NSString stringWithFormat:@"'%@'", [array componentsJoinedByString:@"','"]];
    NSLog(@"fetchQuotesForSymbols: %@", symbols);
    
    NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.quotes where symbol in (%@)", symbols];
    NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
}

- (void)fetchPlotsForSymbol:(NSString *)string callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSString *symbol = [NSString stringWithFormat:@"'%@'", string];
    NSLog(@"fetchPlotsForSymbol: %@", symbol);
    
    NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.historicaldata where symbol in (%@) and startDate = '2013-01-01' and endDate = '2014-01-01'", symbol];
    NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
}


@end
