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


- (void)fetchQuoteForSymbols:(NSString* )symbols callback:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError))callback {
    NSString *url = [NSString stringWithFormat:@"http://www.google.com/finance/info?q=%@", symbols];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:callback];
}

@end
