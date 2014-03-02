//
//  EtradeScraper.m
//  WeTrade
//
//  Created by Jason Wells on 3/1/14.
//  Copyright (c) 2014 Jason Wells. All rights reserved.
//

#import "EtradeScraper.h"

@implementation EtradeScraper

+ (EtradeScraper *)instance {
    static EtradeScraper *instance;
    if (!instance) {
        instance = [[EtradeScraper alloc] init];
    }
    return instance;
}

- (NSString *)source {
    return @"etrade";
}

- (NSURL *)url {
    return [NSURL URLWithString:@"https://us.etrade.com/e/t/stockplan/olportfolioview?ploc=c-SubNav"];
}

- (NSMutableArray* )scrapeWebView:(UIWebView *)webView {
    NSMutableArray *lots = [[NSMutableArray alloc] init];
    
    NSString *string = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('centerTable')[1].outerHTML"];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSRegularExpression *rowsRegex = [NSRegularExpression regularExpressionWithPattern:@"<tr class=\"(even|odd)\" key=\"\\d+\" rn=\"\\d+\">.*?</tr>" options:0 error:nil];
    NSArray *rows = [rowsRegex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *rowMatch in rows) {
        NSString *row = [string substringWithRange:rowMatch.range];
        
        NSString *symbol = @"YHOO";
        NSNumber *price = [self extractCurrencyFrom:row withPattern:@"<td style=\"height: 28px;\" fldnm=\"plan_price\" cn=\"\\d+\" class=\"\">.*?</td>"];
        NSNumber *shares = [self extractDecimalFrom:row withPattern:@"<td style=\"height: 28px;\" fldnm=\"plan_sellable\" cn=\"\\d+\" class=\"\">.*?</td>"];
        float costBasis = (float)[price floatValue] * [shares floatValue];
        
        [lots addObject:[[Lot alloc] initWithSymbol:symbol shares:[shares floatValue] costBasis:costBasis]];
        NSLog(@"Symbol: %@ Shares: %0.3f Price: %0.3f", symbol, [shares floatValue], [price floatValue]);
    }
    return lots;
}

@end
