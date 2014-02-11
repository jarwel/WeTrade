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

- (void)fetchHistoryForSymbol:(NSString *)string startDate:(NSDate *)startDate endDate:(NSDate *)endDate callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *symbol = [NSString stringWithFormat:@"'%@'", string];
    NSString *start = [dateFormatter stringFromDate:startDate];
    NSString *end = [dateFormatter stringFromDate:endDate];
    NSLog(@"fetchHistoryForSymbol: %@ start: %@ end: %@", symbol, start, end);
    
    NSString *query = [NSString stringWithFormat:@"select * from yahoo.finance.historicaldata where symbol in (%@) and startDate = '%@' and endDate = '%@'", symbol, start, end];
    NSString* encoded = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *url = [NSString stringWithFormat:@"http://query.yahooapis.com/v1/public/yql?q=%@&env=store://datatables.org/alltableswithkeys&format=json", encoded];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
}


@end
